import { TrendingUp, TrendingDown, Euro, CreditCard } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { Badge } from "@/components/ui/badge"
import { formatCurrency } from "@/lib/utils"

export function BudgetOverview() {
  const budgetData = [
    { category: 'Alimentation', spent: 280, budget: 400, color: 'bg-blue-500' },
    { category: 'Transport', spent: 120, budget: 150, color: 'bg-green-500' },
    { category: 'Loisirs', spent: 180, budget: 200, color: 'bg-orange-500' },
    { category: 'Santé', spent: 90, budget: 150, color: 'bg-purple-500' },
  ]

  const totalSpent = budgetData.reduce((sum, item) => sum + item.spent, 0)
  const totalBudget = budgetData.reduce((sum, item) => sum + item.budget, 0)
  const remainingBudget = totalBudget - totalSpent

  return (
    <Card className="animate-scale-in">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <CreditCard className="h-5 w-5 text-primary" />
          Aperçu Budget
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Budget total */}
        <div className="flex items-center justify-between p-4 bg-gradient-secondary rounded-lg">
          <div>
            <p className="text-sm text-muted-foreground">Budget restant ce mois</p>
            <p className="text-2xl font-bold text-foreground">{formatCurrency(remainingBudget)}</p>
          </div>
          <div className="flex items-center gap-1">
            {remainingBudget > 0 ? (
              <TrendingUp className="h-4 w-4 text-success" />
            ) : (
              <TrendingDown className="h-4 w-4 text-destructive" />
            )}
            <span className={`text-sm font-medium ${
              remainingBudget > 0 ? 'text-success' : 'text-destructive'
            }`}>
              {((remainingBudget / totalBudget) * 100).toFixed(0)}%
            </span>
          </div>
        </div>

        {/* Répartition par catégorie */}
        <div className="space-y-4">
          <h4 className="text-sm font-medium text-muted-foreground">Dépenses par catégorie</h4>
          {budgetData.map((item) => {
            const percentage = (item.spent / item.budget) * 100
            const isOverBudget = item.spent > item.budget
            
            return (
              <div key={item.category} className="space-y-2">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className={`w-3 h-3 rounded-full ${item.color}`} />
                    <span className="text-sm font-medium">{item.category}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm text-muted-foreground">
                      {formatCurrency(item.spent)} / {formatCurrency(item.budget)}
                    </span>
                    {isOverBudget && (
                      <Badge variant="destructive" className="text-xs">
                        Dépassé
                      </Badge>
                    )}
                  </div>
                </div>
                <Progress 
                  value={Math.min(percentage, 100)} 
                  className="h-2"
                />
              </div>
            )
          })}
        </div>

        {/* Actions rapides */}
        <div className="pt-4 border-t">
          <div className="grid grid-cols-2 gap-3">
            <button className="flex items-center gap-2 p-3 text-sm font-medium bg-muted rounded-lg hover:bg-muted/80 transition-colors">
              <Euro className="h-4 w-4" />
              Ajouter dépense
            </button>
            <button className="flex items-center gap-2 p-3 text-sm font-medium bg-muted rounded-lg hover:bg-muted/80 transition-colors">
              <TrendingUp className="h-4 w-4" />
              Voir détails
            </button>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}