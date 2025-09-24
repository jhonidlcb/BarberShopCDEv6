
import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Button } from '@/components/ui/button';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { PhoneInput } from '@/components/ui/phone-input';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { useToast } from '@/hooks/use-toast';
import { useAdminApi } from '@/hooks/use-admin-api';
import { format } from 'date-fns';
import { es } from 'date-fns/locale';
import { Plus, CalendarPlus } from 'lucide-react';

interface Appointment {
  id: string;
  customerName: string;
  customerPhone: string;
  customerEmail?: string;
  serviceType: string;
  appointmentDate: string;
  appointmentTime: string;
  notes?: string;
  status: string;
  createdAt: string;
}

export function AdminAppointments() {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const api = useAdminApi();
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [newAppointment, setNewAppointment] = useState({
    customerName: '',
    customerPhone: '',
    customerEmail: '',
    serviceType: '',
    appointmentDate: '',
    appointmentTime: '',
    notes: ''
  });

  const { data: appointments, isLoading } = useQuery<Appointment[]>({
    queryKey: ['/api/appointments'],
  });

  const { data: services } = useQuery({
    queryKey: ['/api/admin/services'],
    queryFn: () => api.get('/api/admin/services'),
  });

  const createAppointmentMutation = useMutation({
    mutationFn: async (data: any) => {
      return api.post('/api/appointments', data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/appointments'] });
      toast({ title: 'Cita creada correctamente' });
      setIsDialogOpen(false);
      setNewAppointment({
        customerName: '',
        customerPhone: '',
        customerEmail: '',
        serviceType: '',
        appointmentDate: '',
        appointmentTime: '',
        notes: ''
      });
    },
    onError: (error: any) => {
      toast({ 
        title: 'Error al crear la cita', 
        description: error.message || 'Intenta nuevamente',
        variant: 'destructive' 
      });
    },
  });

  const updateStatusMutation = useMutation({
    mutationFn: async ({ id, status }: { id: string; status: string }) => {
      const response = await fetch(`/api/appointments/${id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status }),
      });
      if (!response.ok) throw new Error('Error updating status');
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/appointments'] });
      toast({ title: 'Estado actualizado correctamente' });
    },
    onError: () => {
      toast({ title: 'Error al actualizar el estado', variant: 'destructive' });
    },
  });

  const handleCreateAppointment = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!newAppointment.customerName || !newAppointment.customerPhone || 
        !newAppointment.serviceType || !newAppointment.appointmentDate || 
        !newAppointment.appointmentTime) {
      toast({
        title: 'Campos requeridos',
        description: 'Por favor completa todos los campos obligatorios',
        variant: 'destructive'
      });
      return;
    }
    
    createAppointmentMutation.mutate(newAppointment);
  };

  const getStatusBadge = (status: string) => {
    const variants = {
      pending: 'secondary',
      confirmed: 'default',
      completed: 'default',
      cancelled: 'destructive',
    } as const;
    
    const labels = {
      pending: 'Pendiente',
      confirmed: 'Confirmada',
      completed: 'Completada',
      cancelled: 'Cancelada',
    };

    return (
      <Badge variant={variants[status as keyof typeof variants] || 'secondary'}>
        {labels[status as keyof typeof labels] || status}
      </Badge>
    );
  };

  if (isLoading) {
    return <div className="text-center py-8">Cargando citas...</div>;
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold text-white">Lista de Citas</h3>
        <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
          <DialogTrigger asChild>
            <Button className="bg-green-500 hover:bg-green-600 text-white">
              <Plus className="h-4 w-4 mr-2" />
              Agendar Cita
            </Button>
          </DialogTrigger>
          <DialogContent className="sm:max-w-[600px] bg-slate-800 text-white border-slate-700">
            <DialogHeader>
              <DialogTitle className="flex items-center gap-2">
                <CalendarPlus className="h-5 w-5" />
                Nueva Cita Manual
              </DialogTitle>
              <DialogDescription className="text-slate-300">
                Crear una nueva cita manualmente desde el panel de administración
              </DialogDescription>
            </DialogHeader>
            <form onSubmit={handleCreateAppointment} className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="customerName">Nombre del Cliente *</Label>
                  <Input
                    id="customerName"
                    value={newAppointment.customerName}
                    onChange={(e) => setNewAppointment({...newAppointment, customerName: e.target.value})}
                    placeholder="Nombre completo"
                    className="bg-slate-700 border-slate-600 text-white"
                    required
                  />
                </div>
                <div>
                  <Label htmlFor="customerPhone">Teléfono *</Label>
                  <PhoneInput
                    value={newAppointment.customerPhone}
                    onChange={(value) => setNewAppointment({...newAppointment, customerPhone: value})}
                    placeholder="Número de teléfono"
                    className="w-full"
                    required
                  />
                </div>
              </div>
              <div>
                <Label htmlFor="customerEmail">Email (Opcional)</Label>
                <Input
                  id="customerEmail"
                  type="email"
                  value={newAppointment.customerEmail}
                  onChange={(e) => setNewAppointment({...newAppointment, customerEmail: e.target.value})}
                  placeholder="email@ejemplo.com"
                  className="bg-slate-700 border-slate-600 text-white"
                />
              </div>
              <div>
                <Label htmlFor="serviceType">Servicio *</Label>
                <Select 
                  value={newAppointment.serviceType}
                  onValueChange={(value) => setNewAppointment({...newAppointment, serviceType: value})}
                  required
                >
                  <SelectTrigger className="bg-slate-700 border-slate-600 text-white">
                    <SelectValue placeholder="Seleccionar servicio..." />
                  </SelectTrigger>
                  <SelectContent className="bg-slate-700 border-slate-600">
                    {services?.map((service: any) => (
                      <SelectItem key={service.id} value={service.id} className="text-white hover:bg-slate-600">
                        {service.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="appointmentDate">Fecha *</Label>
                  <Input
                    id="appointmentDate"
                    type="date"
                    value={newAppointment.appointmentDate}
                    onChange={(e) => setNewAppointment({...newAppointment, appointmentDate: e.target.value})}
                    className="bg-slate-700 border-slate-600 text-white"
                    min={new Date().toISOString().split('T')[0]}
                    required
                  />
                </div>
                <div>
                  <Label htmlFor="appointmentTime">Hora *</Label>
                  <Input
                    id="appointmentTime"
                    type="time"
                    value={newAppointment.appointmentTime}
                    onChange={(e) => setNewAppointment({...newAppointment, appointmentTime: e.target.value})}
                    className="bg-slate-700 border-slate-600 text-white"
                    required
                  />
                </div>
              </div>
              <div>
                <Label htmlFor="notes">Notas Adicionales</Label>
                <Textarea
                  id="notes"
                  value={newAppointment.notes}
                  onChange={(e) => setNewAppointment({...newAppointment, notes: e.target.value})}
                  placeholder="Comentarios o preferencias especiales..."
                  className="bg-slate-700 border-slate-600 text-white"
                  rows={3}
                />
              </div>
              <DialogFooter>
                <Button 
                  type="button" 
                  variant="outline" 
                  onClick={() => setIsDialogOpen(false)}
                  className="border-slate-600 text-slate-300 hover:bg-slate-700"
                >
                  Cancelar
                </Button>
                <Button 
                  type="submit" 
                  disabled={createAppointmentMutation.isPending}
                  className="bg-green-500 hover:bg-green-600"
                >
                  {createAppointmentMutation.isPending ? 'Creando...' : 'Crear Cita'}
                </Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      </div>
      
      <div className="rounded-md border border-slate-700">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Cliente</TableHead>
              <TableHead>Contacto</TableHead>
              <TableHead>Servicio</TableHead>
              <TableHead>Fecha</TableHead>
              <TableHead>Hora</TableHead>
              <TableHead>Estado</TableHead>
              <TableHead>Acciones</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {appointments?.map((appointment) => (
              <TableRow key={appointment.id}>
                <TableCell className="font-medium">
                  {appointment.customerName}
                </TableCell>
                <TableCell>
                  <div className="text-sm">
                    <div>{appointment.customerPhone}</div>
                    {appointment.customerEmail && (
                      <div className="text-muted-foreground">{appointment.customerEmail}</div>
                    )}
                  </div>
                </TableCell>
                <TableCell>{appointment.serviceType}</TableCell>
                <TableCell>
                  {format(new Date(appointment.appointmentDate), 'dd/MM/yyyy', { locale: es })}
                </TableCell>
                <TableCell>{appointment.appointmentTime}</TableCell>
                <TableCell>{getStatusBadge(appointment.status)}</TableCell>
                <TableCell>
                  <Select
                    value={appointment.status}
                    onValueChange={(status) => 
                      updateStatusMutation.mutate({ id: appointment.id, status })
                    }
                  >
                    <SelectTrigger className="w-32">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="pending">Pendiente</SelectItem>
                      <SelectItem value="confirmed">Confirmada</SelectItem>
                      <SelectItem value="completed">Completada</SelectItem>
                      <SelectItem value="cancelled">Cancelada</SelectItem>
                    </SelectContent>
                  </Select>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
