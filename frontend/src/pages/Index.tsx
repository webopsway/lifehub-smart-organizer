import { DashboardHeader } from "@/components/dashboard/dashboard-header"
import { QuickStats } from "@/components/dashboard/quick-stats"
import { TaskList } from "@/components/dashboard/task-list"
import { ShoppingList } from "@/components/dashboard/shopping-list"
import { BudgetOverview } from "@/components/dashboard/budget-overview"

const Index = () => {
  return (
    <div className="min-h-screen bg-background">
      <DashboardHeader />
      
      <main className="container mx-auto p-6 space-y-6">
        <QuickStats />
        
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          <div className="lg:col-span-2">
            <TaskList />
          </div>
          <div>
            <ShoppingList />
          </div>
        </div>
        
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          <div className="lg:col-span-1">
            <BudgetOverview />
          </div>
        </div>
      </main>
    </div>
  );
};

export default Index;
