import { CheckSquare, ShoppingCart, DollarSign, Calendar } from "lucide-react"
import { StatCard } from "@/components/ui/stat-card"

export function QuickStats() {
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4 animate-slide-up">
      <StatCard
        title="Tâches complétées"
        value="8/12"
        icon={<CheckSquare className="h-4 w-4" />}
        trend={{ value: 15, label: "vs hier", isPositive: true }}
      />
      
      <StatCard
        title="Articles à acheter"
        value="7"
        icon={<ShoppingCart className="h-4 w-4" />}
      />
      
      <StatCard
        title="Budget restant"
        value="340€"
        icon={<DollarSign className="h-4 w-4" />}
        trend={{ value: -5, label: "vs semaine dernière", isPositive: false }}
      />
      
      <StatCard
        title="RDV cette semaine"
        value="3"
        icon={<Calendar className="h-4 w-4" />}
      />
    </div>
  )
}