import * as React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { cn } from "@/lib/utils"

interface StatCardProps {
  title: string
  value: string | number
  icon?: React.ReactNode
  trend?: {
    value: number
    label: string
    isPositive?: boolean
  }
  className?: string
}

const StatCard = React.forwardRef<HTMLDivElement, StatCardProps>(
  ({ title, value, icon, trend, className, ...props }, ref) => {
    return (
      <Card 
        ref={ref} 
        className={cn(
          "relative overflow-hidden transition-all duration-300 hover:shadow-elegant hover:-translate-y-1 animate-fade-in",
          className
        )} 
        {...props}
      >
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium text-muted-foreground">
            {title}
          </CardTitle>
          {icon && (
            <div className="h-4 w-4 text-muted-foreground">
              {icon}
            </div>
          )}
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold text-foreground">{value}</div>
          {trend && (
            <div className="flex items-center space-x-1 text-xs">
              <span 
                className={cn(
                  "font-medium",
                  trend.isPositive ? "text-success" : "text-destructive"
                )}
              >
                {trend.isPositive ? "+" : ""}{trend.value}%
              </span>
              <span className="text-muted-foreground">{trend.label}</span>
            </div>
          )}
        </CardContent>
      </Card>
    )
  }
)
StatCard.displayName = "StatCard"

export { StatCard }