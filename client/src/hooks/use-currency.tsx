
import { createContext, useContext, useState, useEffect, ReactNode } from 'react';

type Currency = 'USD' | 'BRL' | 'PYG';

interface CurrencyContextType {
  currency: Currency;
  setCurrency: (currency: Currency) => void;
  formatPrice: (priceUsd: number, priceBrl: number, pricePyg: number) => string;
  getCurrencySymbol: (currency: Currency) => string;
}

const CurrencyContext = createContext<CurrencyContextType | undefined>(undefined);

interface CurrencyProviderProps {
  children: ReactNode;
}

export function CurrencyProvider({ children }: CurrencyProviderProps) {
  const [currency, setCurrency] = useState<Currency>('USD');

  useEffect(() => {
    const savedCurrency = localStorage.getItem('currency') as Currency;
    if (savedCurrency && ['USD', 'BRL', 'PYG'].includes(savedCurrency)) {
      setCurrency(savedCurrency);
    }
  }, []);

  const handleSetCurrency = (newCurrency: Currency) => {
    setCurrency(newCurrency);
    localStorage.setItem('currency', newCurrency);
  };

  const getCurrencySymbol = (curr: Currency): string => {
    const symbols = {
      USD: '$',
      BRL: 'R$',
      PYG: '₲'
    };
    return symbols[curr];
  };

  const formatPrice = (priceUsd: number, priceBrl: number, pricePyg: number): string => {
    const prices = {
      USD: priceUsd || 0,
      BRL: priceBrl || 0,
      PYG: pricePyg || 0
    };

    const price = prices[currency];
    const symbol = getCurrencySymbol(currency);

    if (currency === 'PYG') {
      return `${symbol} ${price.toLocaleString('es-PY')}`;
    } else if (currency === 'BRL') {
      return `${symbol} ${price.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    } else {
      return `${symbol} ${price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    }
  };

  const value: CurrencyContextType = {
    currency,
    setCurrency: handleSetCurrency,
    formatPrice,
    getCurrencySymbol
  };

  return (
    <CurrencyContext.Provider value={value}>
      {children}
    </CurrencyContext.Provider>
  );
}

export function useCurrency() {
  const context = useContext(CurrencyContext);
  if (context === undefined) {
    throw new Error('useCurrency must be used within a CurrencyProvider');
  }
  return context;
}
