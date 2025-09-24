import { drizzle } from "drizzle-orm/neon-http";
import { neon } from "@neondatabase/serverless";
import { eq, desc, and, or, like } from "drizzle-orm";
import {
  users,
  appointments,
  blogPosts,
  reviews,
  services,
  galleryImages,
  companyInfo,
  siteConfig,
  adminUsers,
  adminSessions,
  currencySettings,
  languageSettings,
  staffMembers,
  workingHours,
  serviceHours,
  type User,
  type InsertUser,
  type Appointment,
  type InsertAppointment,
  type BlogPost,
  type InsertBlogPost,
  type Review,
  type InsertReview,
  type Service,
  type InsertService,
  type GalleryImage,
  type InsertGalleryImage,
  type CompanyInfo,
  type InsertCompanyInfo,
  type SiteConfig,
  type InsertSiteConfig,
  type AdminUser,
  type InsertAdminUser,
  type AdminSession,
  type InsertAdminSession,
  type CurrencySettings,
  type InsertCurrencySettings,
  type LanguageSettings,
  type InsertLanguageSettings,
  type StaffMember,
  type InsertStaffMember,
  type WorkingHours,
  type InsertWorkingHours,
  type ServiceHours,
  type InsertServiceHours
} from "@shared/schema";

// Verify DATABASE_URL is configured
if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL environment variable is not set. Please configure it in Secrets.");
}

// Log the DATABASE_URL (without showing the full connection string for security)
console.log("🔌 Database URL configured:", process.env.DATABASE_URL ? "✅ SET" : "❌ NOT SET");
console.log("🔌 Connecting to Neon PostgreSQL...");

// Verify it's the correct Neon database
const expectedHost = "ep-still-term-acjgon5c-pooler.sa-east-1.aws.neon.tech";
const currentUrl = process.env.DATABASE_URL;
if (!currentUrl?.includes(expectedHost)) {
  console.warn("⚠️  Warning: DATABASE_URL might not be pointing to the expected Neon database");
  console.log("Expected host:", expectedHost);
  console.log("Current URL contains expected host:", currentUrl?.includes(expectedHost));
} else {
  console.log("✅ Connected to correct Neon database:", expectedHost);
}

// Create Neon SQL connection
const sql = neon(process.env.DATABASE_URL!);

// Create Drizzle database instance
export const db = drizzle(sql, {
  schema: {
    users,
    appointments,
    blogPosts,
    reviews,
    siteConfig,
    services,
    galleryImages,
    companyInfo,
    adminUsers,
    adminSessions,
    currencySettings,
    languageSettings,
    staffMembers,
    workingHours,
    serviceHours
  }
});

// User operations
export const getUser = async (username: string) => {
  const result = await db.select().from(users).where(eq(users.username, username)).limit(1);
  return result[0];
};

export const createUser = async (userData: InsertUser) => {
  const result = await db.insert(users).values(userData).returning();
  return result[0];
};

// Admin operations
export const getAdminUser = async (id: string) => {
  const result = await db.select().from(adminUsers).where(eq(adminUsers.id, id)).limit(1);
  return result[0];
};

export const getAdminUserByUsername = async (username: string) => {
  const result = await db.select().from(adminUsers).where(eq(adminUsers.username, username)).limit(1);
  return result[0];
};

export const getAdminUserByEmail = async (email: string) => {
  const result = await db.select().from(adminUsers).where(eq(adminUsers.email, email)).limit(1);
  return result[0];
};

export const createAdminUser = async (userData: InsertAdminUser) => {
  const result = await db.insert(adminUsers).values(userData).returning();
  return result[0];
};

export const createAdminSession = async (sessionData: InsertAdminSession) => {
  const result = await db.insert(adminSessions).values(sessionData).returning();
  return result[0];
};

export const getAdminSession = async (token: string) => {
  const result = await db.select()
    .from(adminSessions)
    .where(eq(adminSessions.token, token))
    .orderBy(desc(adminSessions.expiresAt))
    .limit(1);

  // Check if session exists and is not expired
  if (result[0] && new Date() <= result[0].expiresAt) {
    return result[0];
  }
  return undefined;
};

export const deleteAdminSession = async (token: string) => {
  await db.delete(adminSessions).where(eq(adminSessions.token, token));
};

// Appointments operations
export const getAppointments = async () => {
  return await db.select().from(appointments).orderBy(desc(appointments.createdAt));
};

export const getAppointmentsByDate = async (date: string) => {
  console.log(`Storage: Getting appointments for date ${date}`);
  const result = await db.select().from(appointments).where(eq(appointments.appointmentDate, date));
  console.log(`Storage: Found ${result.length} appointments:`, result.map(apt => ({
    id: apt.id,
    customerName: apt.customerName,
    appointmentTime: apt.appointmentTime,
    status: apt.status
  })));
  return result;
};

export const createAppointment = async (appointmentData: InsertAppointment) => {
  const result = await db.insert(appointments).values(appointmentData).returning();
  return result[0];
};

export const updateAppointment = async (id: string, appointmentData: Partial<InsertAppointment>) => {
  const result = await db.update(appointments)
    .set({ ...appointmentData, createdAt: new Date() })
    .where(eq(appointments.id, id))
    .returning();
  return result[0];
};

export const updateAppointmentStatus = async (id: string, status: string) => {
  const result = await db.update(appointments)
    .set({ status })
    .where(eq(appointments.id, id))
    .returning();
  return result[0];
};

export const deleteAppointment = async (id: string) => {
  await db.delete(appointments).where(eq(appointments.id, id));
};

// Services operations
export const getServices = async () => {
  return await db.select().from(services).orderBy(services.sortOrder);
};

export const getActiveServices = async () => {
  return await db.select().from(services)
    .where(eq(services.active, true))
    .orderBy(services.sortOrder);
};

export const createService = async (serviceData: InsertService) => {
  const result = await db.insert(services).values(serviceData).returning();
  return result[0];
};

export const updateService = async (id: string, serviceData: Partial<InsertService>) => {
  const result = await db.update(services)
    .set({ ...serviceData, updatedAt: new Date() })
    .where(eq(services.id, id))
    .returning();
  return result[0];
};

export const deleteService = async (id: string) => {
  await db.delete(services).where(eq(services.id, id));
};

// Reviews operations
export const getApprovedReviews = async () => {
  return await db.select().from(reviews)
    .where(eq(reviews.approved, true))
    .orderBy(desc(reviews.createdAt));
};

export const getReviews = async () => {
  return await db.select().from(reviews).orderBy(desc(reviews.createdAt));
};

export const createReview = async (reviewData: InsertReview) => {
  const result = await db.insert(reviews).values(reviewData).returning();
  return result[0];
};

export const updateReview = async (id: string, reviewData: Partial<InsertReview>) => {
  const result = await db.update(reviews)
    .set(reviewData)
    .where(eq(reviews.id, id))
    .returning();
  return result[0];
};

export const approveReview = async (id: string) => {
  const result = await db.update(reviews)
    .set({ approved: true })
    .where(eq(reviews.id, id))
    .returning();
  return result[0];
};

export const deleteReview = async (id: string) => {
  await db.delete(reviews).where(eq(reviews.id, id));
};

// Gallery operations
export const getActiveGalleryImages = async () => {
  return await db.select().from(galleryImages)
    .where(eq(galleryImages.active, true))
    .orderBy(galleryImages.sortOrder);
};

export const getGalleryImages = async () => {
  return await db.select().from(galleryImages).orderBy(galleryImages.sortOrder);
};

export const createGalleryImage = async (imageData: InsertGalleryImage) => {
  const result = await db.insert(galleryImages).values(imageData).returning();
  return result[0];
};

export const updateGalleryImage = async (id: string, imageData: Partial<InsertGalleryImage>) => {
  const result = await db.update(galleryImages)
    .set(imageData)
    .where(eq(galleryImages.id, id))
    .returning();
  return result[0];
};

export const deleteGalleryImage = async (id: string) => {
  await db.delete(galleryImages).where(eq(galleryImages.id, id));
};

// Blog operations
export const getPublishedBlogPosts = async () => {
  return await db.select().from(blogPosts)
    .where(eq(blogPosts.published, true))
    .orderBy(desc(blogPosts.createdAt));
};

export const getBlogPosts = async () => {
  return await db.select().from(blogPosts).orderBy(desc(blogPosts.createdAt));
};

export const getBlogPost = async (slug: string) => {
  const result = await db.select().from(blogPosts)
    .where(eq(blogPosts.slug, slug))
    .limit(1);
  return result[0];
};

export const getBlogPostsByCategory = async (category: string) => {
  return await db.select().from(blogPosts)
    .where(and(
      eq(blogPosts.category, category),
      eq(blogPosts.published, true)
    ))
    .orderBy(desc(blogPosts.createdAt));
};

export const createBlogPost = async (postData: InsertBlogPost) => {
  const result = await db.insert(blogPosts).values(postData).returning();
  return result[0];
};

export const updateBlogPost = async (id: string, postData: Partial<InsertBlogPost>) => {
  const result = await db.update(blogPosts)
    .set({ ...postData, updatedAt: new Date() })
    .where(eq(blogPosts.id, id))
    .returning();
  return result[0];
};

export const deleteBlogPost = async (id: string) => {
  await db.delete(blogPosts).where(eq(blogPosts.id, id));
};

// Company info operations
export const getCompanyInfo = async () => {
  return await db.select().from(companyInfo).orderBy(companyInfo.section);
};

export const getCompanyInfoBySection = async (section: string) => {
  const result = await db.select().from(companyInfo)
    .where(eq(companyInfo.section, section))
    .limit(1);
  return result[0];
};

export const upsertCompanyInfo = async (infoData: any) => {
  const existing = await getCompanyInfoBySection(infoData.section);

  const updateData = {
    section: infoData.section,
    title: infoData.title || null,
    titlePt: infoData.titlePt || null,
    content: infoData.content || null,
    contentPt: infoData.contentPt || null,
    content2: infoData.content2 || null,
    content2Pt: infoData.content2Pt || null,
    imageUrl: infoData.imageUrl || null,
    barberName: infoData.barberName || null,
    barberTitle: infoData.barberTitle || null,
    barberTitlePt: infoData.barberTitlePt || null,
    yearsExperience: infoData.yearsExperience || null,
    totalClients: infoData.totalClients || null,
    satisfaction: infoData.satisfaction || null,
    metadata: infoData.metadata || null,
    updatedAt: new Date()
  };

  if (existing) {
    const result = await db
      .update(companyInfo)
      .set(updateData)
      .where(eq(companyInfo.section, infoData.section))
      .returning();
    return result[0];
  } else {
    const insertData = {
      ...updateData,
      createdAt: new Date()
    };
    const result = await db
      .insert(companyInfo)
      .values(insertData)
      .returning();
    return result[0];
  }
};

// Site config operations
export const getSiteConfig = async () => {
  const result = await db.select().from(siteConfig).orderBy(siteConfig.key);
  return result.reduce((acc, config) => {
    acc[config.key] = config.value;
    return acc;
  }, {} as Record<string, string>);
};

export const getSiteConfigByKey = async (key: string) => {
  const result = await db.select().from(siteConfig)
    .where(eq(siteConfig.key, key))
    .limit(1);
  return result[0];
};

export const updateSiteConfig = async (configData: Record<string, string>) => {
  const results = [];

  for (const [key, value] of Object.entries(configData)) {
    const existing = await getSiteConfigByKey(key);

    if (existing) {
      const result = await db.update(siteConfig)
        .set({ value, updatedAt: new Date() })
        .where(eq(siteConfig.key, key))
        .returning();
      results.push(result[0]);
    } else {
      const result = await db.insert(siteConfig)
        .values({ key, value })
        .returning();
      results.push(result[0]);
    }
  }

  return results;
};

export const createSiteConfig = async (configData: InsertSiteConfig) => {
  const result = await db.insert(siteConfig).values(configData).returning();
  return result[0];
};

// Currency settings operations
export const getCurrencySettings = async () => {
  return await db.select().from(currencySettings).where(eq(currencySettings.isActive, true));
};

export const getAllCurrencySettings = async () => {
  return await db.select().from(currencySettings);
};

export const updateCurrencySettings = async (id: number, data: Partial<InsertCurrencySettings>) => {
  const result = await db.update(currencySettings)
    .set({ ...data, updatedAt: new Date() })
    .where(eq(currencySettings.id, id))
    .returning();
  return result[0];
};

// Language settings operations
export const getLanguageSettings = async () => {
  return await db.select().from(languageSettings).where(eq(languageSettings.isActive, true));
};

export const getAllLanguageSettings = async () => {
  return await db.select().from(languageSettings);
};

export const getDefaultLanguage = async () => {
  const result = await db.select().from(languageSettings).where(eq(languageSettings.isDefault, true)).limit(1);
  return result[0];
};

export const updateLanguageSettings = async (id: number, data: Partial<InsertLanguageSettings>) => {
  const result = await db.update(languageSettings)
    .set(data)
    .where(eq(languageSettings.id, id))
    .returning();
  return result[0];
};

// Test database connection
export const testConnection = async () => {
  try {
    await db.select().from(users).limit(1);
    console.log("✅ Database connection successful");
    return true;
  } catch (error) {
    console.error("❌ Database connection failed:", error);
    return false;
  }
};

// Staff operations
export const getActiveStaffMembers = async () => {
  return await db.select().from(staffMembers)
    .where(eq(staffMembers.active, true))
    .orderBy(staffMembers.sortOrder);
};

export const getAllStaffMembers = async () => {
  return await db.select().from(staffMembers).orderBy(staffMembers.sortOrder);
};

export const createStaffMember = async (memberData: InsertStaffMember) => {
  const result = await db.insert(staffMembers).values(memberData).returning();
  return result[0];
};

export const updateStaffMember = async (id: string, memberData: Partial<InsertStaffMember>) => {
  const result = await db.update(staffMembers)
    .set({ ...memberData, updatedAt: new Date() })
    .where(eq(staffMembers.id, id))
    .returning();
  return result[0];
};

export const deleteStaffMember = async (id: string) => {
  await db.delete(staffMembers).where(eq(staffMembers.id, id));
};

// Working hours operations (business hours)
export const getWorkingHours = async () => {
  return await db.select().from(workingHours)
    .where(eq(workingHours.active, true))
    .orderBy(workingHours.dayOfWeek);
};

export const updateWorkingHours = async (id: string, hoursData: Partial<InsertWorkingHours>) => {
  // Remove updatedAt from hoursData if it exists and ensure it's properly set
  const { updatedAt, ...cleanHoursData } = hoursData;
  
  const result = await db.update(workingHours)
    .set({ 
      ...cleanHoursData,
      updatedAt: new Date()
    })
    .where(eq(workingHours.id, id))
    .returning();
  return result[0];
};

export const getWorkingHoursByDay = async (dayOfWeek: number) => {
  const result = await db.select().from(workingHours)
    .where(and(eq(workingHours.dayOfWeek, dayOfWeek), eq(workingHours.active, true)))
    .limit(1);
  return result[0];
};

// Service hours operations (appointment booking hours)
export const getServiceHours = async () => {
  return await db.select().from(serviceHours)
    .where(eq(serviceHours.active, true))
    .orderBy(serviceHours.dayOfWeek);
};

export const updateServiceHours = async (id: string, hoursData: Partial<InsertServiceHours>) => {
  // Remove all timestamp fields from hoursData and ensure they're properly set
  const { updatedAt, createdAt, ...cleanHoursData } = hoursData;
  
  const result = await db.update(serviceHours)
    .set({ 
      ...cleanHoursData,
      updatedAt: new Date()
    })
    .where(eq(serviceHours.id, id))
    .returning();
  return result[0];
};

export const getServiceHoursByDay = async (dayOfWeek: number) => {
  const result = await db.select().from(serviceHours)
    .where(and(eq(serviceHours.dayOfWeek, dayOfWeek), eq(serviceHours.active, true)))
    .limit(1);
  return result[0];
};

// Export storage object for compatibility
export const storage = {
  // User operations
  getUser,
  createUser,

  // Admin operations
  getAdminUser,
  getAdminUserByUsername,
  getAdminUserByEmail,
  createAdminUser,
  createAdminSession,
  getAdminSession,
  deleteAdminSession,

  // Appointments
  getAppointments,
  getAppointmentsByDate,
  createAppointment,
  updateAppointment,
  updateAppointmentStatus,
  deleteAppointment,

  // Services
  getServices,
  getActiveServices,
  createService,
  updateService,
  deleteService,

  // Reviews
  getApprovedReviews,
  getReviews,
  createReview,
  updateReview,
  approveReview,
  deleteReview,

  // Gallery
  getActiveGalleryImages,
  getGalleryImages,
  createGalleryImage,
  updateGalleryImage,
  deleteGalleryImage,

  // Blog
  getPublishedBlogPosts,
  getBlogPosts,
  getBlogPost,
  getBlogPostsByCategory,
  createBlogPost,
  updateBlogPost,
  deleteBlogPost,

  // Company info
  getCompanyInfo,
  getCompanyInfoBySection,
  upsertCompanyInfo,

  // Site config
  getSiteConfig,
  getSiteConfigByKey,
  updateSiteConfig,
  createSiteConfig,

  // Currency settings
  getCurrencySettings,
  getAllCurrencySettings,
  updateCurrencySettings,

  // Language settings
  getLanguageSettings,
  getAllLanguageSettings,
  getDefaultLanguage,
  updateLanguageSettings,

  // Staff operations
  getActiveStaffMembers,
  getAllStaffMembers,
  createStaffMember,
  updateStaffMember,
  deleteStaffMember,

  // Working hours
  getWorkingHours,
  updateWorkingHours,
  getWorkingHoursByDay,

  // Service hours
  getServiceHours,
  updateServiceHours,
  getServiceHoursByDay,

  // Test
  testConnection
};