import axios, { AxiosInstance, AxiosResponse } from 'axios';

// Configuration de base
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

// Interface pour les réponses d'erreur
interface ApiError {
  detail: string;
  status_code?: number;
}

// Interface pour les réponses de login
interface LoginResponse {
  access_token: string;
  token_type: string;
  user: {
    id: number;
    email: string;
    username: string;
    full_name: string;
    avatar_url?: string;
  };
}

// Interface pour l'utilisateur
interface User {
  id: number;
  email: string;
  username: string;
  first_name?: string;
  last_name?: string;
  full_name: string;
  avatar_url?: string;
  is_active: boolean;
  is_superuser: boolean;
  timezone: string;
  created_at: string;
  updated_at: string;
}

// Interface pour les tâches
interface Task {
  id: number;
  title: string;
  description?: string;
  priority: 'low' | 'medium' | 'high';
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled';
  completed: boolean;
  due_date?: string;
  completed_at?: string;
  created_at: string;
  updated_at: string;
  user_id: number;
}

// Interface pour les articles de courses
interface ShoppingItem {
  id: number;
  name: string;
  quantity: number;
  unit: string;
  estimated_price?: number;
  actual_price?: number;
  category: string;
  notes?: string;
  completed: boolean;
  purchased_at?: string;
  created_at: string;
  updated_at: string;
  user_id: number;
  total_estimated_cost: number;
  total_actual_cost: number;
}

// Interface pour les catégories de budget
interface BudgetCategory {
  id: number;
  name: string;
  category_type: string;
  monthly_budget: number;
  color: string;
  icon?: string;
  description?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  user_id: number;
  spent_this_month: number;
  remaining_budget: number;
  budget_percentage_used: number;
}

// Interface pour les transactions de budget
interface BudgetTransaction {
  id: number;
  title: string;
  description?: string;
  amount: number;
  transaction_type: 'income' | 'expense' | 'transfer';
  transaction_date: string;
  receipt_url?: string;
  tags?: string;
  is_recurring: boolean;
  recurring_interval?: string;
  created_at: string;
  updated_at: string;
  user_id: number;
  category_id?: number;
  tags_list: string[];
}

// Interface pour l'aperçu du budget
interface BudgetOverview {
  total_budget: number;
  total_spent: number;
  remaining_budget: number;
  categories: BudgetCategory[];
}

class ApiClient {
  private axiosInstance: AxiosInstance;

  constructor() {
    this.axiosInstance = axios.create({
      baseURL: API_BASE_URL,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Intercepteur pour ajouter le token d'authentification
    this.axiosInstance.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('access_token');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // Intercepteur pour gérer les erreurs de réponse
    this.axiosInstance.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          // Token expiré ou invalide
          localStorage.removeItem('access_token');
          localStorage.removeItem('user');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  // === AUTHENTIFICATION ===

  async login(email: string, password: string): Promise<LoginResponse> {
    const formData = new FormData();
    formData.append('username', email);
    formData.append('password', password);

    const response = await this.axiosInstance.post<LoginResponse>('/auth/login', formData, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    });
    
    return response.data;
  }

  async register(userData: {
    email: string;
    username: string;
    password: string;
    first_name?: string;
    last_name?: string;
  }): Promise<User> {
    const response = await this.axiosInstance.post<User>('/auth/register', userData);
    return response.data;
  }

  // === UTILISATEURS ===

  async getCurrentUser(): Promise<User> {
    const response = await this.axiosInstance.get<User>('/users/me');
    return response.data;
  }

  async updateCurrentUser(userData: Partial<User>): Promise<User> {
    const response = await this.axiosInstance.put<User>('/users/me', userData);
    return response.data;
  }

  // === TÂCHES ===

  async getTasks(filters?: {
    completed?: boolean;
    priority?: string;
    skip?: number;
    limit?: number;
  }): Promise<Task[]> {
    const response = await this.axiosInstance.get<Task[]>('/tasks', { params: filters });
    return response.data;
  }

  async getTask(taskId: number): Promise<Task> {
    const response = await this.axiosInstance.get<Task>(`/tasks/${taskId}`);
    return response.data;
  }

  async createTask(taskData: {
    title: string;
    description?: string;
    priority?: 'low' | 'medium' | 'high';
    due_date?: string;
  }): Promise<Task> {
    const response = await this.axiosInstance.post<Task>('/tasks', taskData);
    return response.data;
  }

  async updateTask(taskId: number, taskData: Partial<Task>): Promise<Task> {
    const response = await this.axiosInstance.put<Task>(`/tasks/${taskId}`, taskData);
    return response.data;
  }

  async deleteTask(taskId: number): Promise<void> {
    await this.axiosInstance.delete(`/tasks/${taskId}`);
  }

  async toggleTask(taskId: number): Promise<Task> {
    const response = await this.axiosInstance.patch<Task>(`/tasks/${taskId}/toggle`);
    return response.data;
  }

  // === COURSES ===

  async getShoppingItems(filters?: {
    completed?: boolean;
    category?: string;
    skip?: number;
    limit?: number;
  }): Promise<ShoppingItem[]> {
    const response = await this.axiosInstance.get<ShoppingItem[]>('/shopping', { params: filters });
    return response.data;
  }

  async createShoppingItem(itemData: {
    name: string;
    quantity?: number;
    unit?: string;
    estimated_price?: number;
    category?: string;
    notes?: string;
  }): Promise<ShoppingItem> {
    const response = await this.axiosInstance.post<ShoppingItem>('/shopping', itemData);
    return response.data;
  }

  async updateShoppingItem(itemId: number, itemData: Partial<ShoppingItem>): Promise<ShoppingItem> {
    const response = await this.axiosInstance.put<ShoppingItem>(`/shopping/${itemId}`, itemData);
    return response.data;
  }

  async deleteShoppingItem(itemId: number): Promise<void> {
    await this.axiosInstance.delete(`/shopping/${itemId}`);
  }

  async toggleShoppingItem(itemId: number, actualPrice?: number): Promise<ShoppingItem> {
    const params = actualPrice ? { actual_price: actualPrice } : {};
    const response = await this.axiosInstance.patch<ShoppingItem>(`/shopping/${itemId}/toggle`, null, { params });
    return response.data;
  }

  async getShoppingSummary(): Promise<{
    total_items: number;
    completed_items: number;
    pending_items: number;
    completion_rate: number;
  }> {
    const response = await this.axiosInstance.get('/shopping/stats/summary');
    return response.data;
  }

  // === BUDGET ===

  async getBudgetCategories(): Promise<BudgetCategory[]> {
    const response = await this.axiosInstance.get<BudgetCategory[]>('/budget/categories');
    return response.data;
  }

  async createBudgetCategory(categoryData: {
    name: string;
    category_type: string;
    monthly_budget: number;
    color?: string;
    icon?: string;
    description?: string;
  }): Promise<BudgetCategory> {
    const response = await this.axiosInstance.post<BudgetCategory>('/budget/categories', categoryData);
    return response.data;
  }

  async getBudgetTransactions(filters?: {
    category_id?: number;
    transaction_type?: string;
    start_date?: string;
    end_date?: string;
    skip?: number;
    limit?: number;
  }): Promise<BudgetTransaction[]> {
    const response = await this.axiosInstance.get<BudgetTransaction[]>('/budget/transactions', { params: filters });
    return response.data;
  }

  async createBudgetTransaction(transactionData: {
    title: string;
    description?: string;
    amount: number;
    transaction_type: 'income' | 'expense' | 'transfer';
    transaction_date?: string;
    category_id?: number;
    tags?: string;
  }): Promise<BudgetTransaction> {
    const response = await this.axiosInstance.post<BudgetTransaction>('/budget/transactions', transactionData);
    return response.data;
  }

  async getBudgetOverview(): Promise<BudgetOverview> {
    const response = await this.axiosInstance.get<BudgetOverview>('/budget/overview');
    return response.data;
  }
}

// Instance singleton du client API
export const apiClient = new ApiClient();

// Export des types pour utilisation dans les composants
export type {
  User,
  Task,
  ShoppingItem,
  BudgetCategory,
  BudgetTransaction,
  BudgetOverview,
  LoginResponse,
  ApiError,
}; 