import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient, Task, ShoppingItem, BudgetCategory, BudgetOverview } from '@/lib/api';
import { toast } from 'sonner';

// === HOOKS POUR LES TÂCHES ===

export function useTasks(filters?: {
  completed?: boolean;
  priority?: string;
}) {
  return useQuery({
    queryKey: ['tasks', filters],
    queryFn: () => apiClient.getTasks(filters),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

export function useCreateTask() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (taskData: {
      title: string;
      description?: string;
      priority?: 'low' | 'medium' | 'high';
      due_date?: string;
    }) => apiClient.createTask(taskData),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
      toast.success('Tâche créée avec succès');
    },
    onError: (error: any) => {
      toast.error('Erreur lors de la création de la tâche');
      console.error('Error creating task:', error);
    },
  });
}

export function useUpdateTask() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ taskId, taskData }: { taskId: number; taskData: Partial<Task> }) =>
      apiClient.updateTask(taskId, taskData),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
      toast.success('Tâche mise à jour');
    },
    onError: (error: any) => {
      toast.error('Erreur lors de la mise à jour');
      console.error('Error updating task:', error);
    },
  });
}

export function useToggleTask() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (taskId: number) => apiClient.toggleTask(taskId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
    onError: (error: any) => {
      toast.error('Erreur lors de la modification');
      console.error('Error toggling task:', error);
    },
  });
}

export function useDeleteTask() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (taskId: number) => apiClient.deleteTask(taskId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
      toast.success('Tâche supprimée');
    },
    onError: (error: any) => {
      toast.error('Erreur lors de la suppression');
      console.error('Error deleting task:', error);
    },
  });
}

// === HOOKS POUR LES COURSES ===

export function useShoppingItems(filters?: {
  completed?: boolean;
  category?: string;
}) {
  return useQuery({
    queryKey: ['shopping', filters],
    queryFn: () => apiClient.getShoppingItems(filters),
    staleTime: 5 * 60 * 1000,
  });
}

export function useCreateShoppingItem() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (itemData: {
      name: string;
      quantity?: number;
      unit?: string;
      estimated_price?: number;
      category?: string;
      notes?: string;
    }) => apiClient.createShoppingItem(itemData),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['shopping'] });
      toast.success('Article ajouté à la liste');
    },
    onError: (error: any) => {
      toast.error('Erreur lors de l\'ajout');
      console.error('Error creating shopping item:', error);
    },
  });
}

export function useUpdateShoppingItem() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ itemId, itemData }: { itemId: number; itemData: Partial<ShoppingItem> }) =>
      apiClient.updateShoppingItem(itemId, itemData),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['shopping'] });
      toast.success('Article mis à jour');
    },
    onError: (error: any) => {
      toast.error('Erreur lors de la mise à jour');
      console.error('Error updating shopping item:', error);
    },
  });
}

export function useToggleShoppingItem() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ itemId, actualPrice }: { itemId: number; actualPrice?: number }) =>
      apiClient.toggleShoppingItem(itemId, actualPrice),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['shopping'] });
    },
    onError: (error: any) => {
      toast.error('Erreur lors de la modification');
      console.error('Error toggling shopping item:', error);
    },
  });
}

export function useDeleteShoppingItem() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (itemId: number) => apiClient.deleteShoppingItem(itemId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['shopping'] });
      toast.success('Article supprimé');
    },
    onError: (error: any) => {
      toast.error('Erreur lors de la suppression');
      console.error('Error deleting shopping item:', error);
    },
  });
}

export function useShoppingSummary() {
  return useQuery({
    queryKey: ['shopping', 'summary'],
    queryFn: () => apiClient.getShoppingSummary(),
    staleTime: 2 * 60 * 1000, // 2 minutes
  });
}

// === HOOKS POUR LE BUDGET ===

export function useBudgetCategories() {
  return useQuery({
    queryKey: ['budget', 'categories'],
    queryFn: () => apiClient.getBudgetCategories(),
    staleTime: 10 * 60 * 1000, // 10 minutes
  });
}

export function useCreateBudgetCategory() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (categoryData: {
      name: string;
      category_type: string;
      monthly_budget: number;
      color?: string;
      icon?: string;
      description?: string;
    }) => apiClient.createBudgetCategory(categoryData),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['budget'] });
      toast.success('Catégorie créée');
    },
    onError: (error: any) => {
      toast.error('Erreur lors de la création');
      console.error('Error creating budget category:', error);
    },
  });
}

export function useBudgetOverview() {
  return useQuery({
    queryKey: ['budget', 'overview'],
    queryFn: () => apiClient.getBudgetOverview(),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

export function useCreateBudgetTransaction() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (transactionData: {
      title: string;
      description?: string;
      amount: number;
      transaction_type: 'income' | 'expense' | 'transfer';
      transaction_date?: string;
      category_id?: number;
      tags?: string;
    }) => apiClient.createBudgetTransaction(transactionData),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['budget'] });
      toast.success('Transaction ajoutée');
    },
    onError: (error: any) => {
      toast.error('Erreur lors de l\'ajout');
      console.error('Error creating budget transaction:', error);
    },
  });
} 