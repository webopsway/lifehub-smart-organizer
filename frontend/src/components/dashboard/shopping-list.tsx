import { useState } from "react"
import { ShoppingCart, Plus, Check, Trash2 } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"

interface ShoppingItem {
  id: string
  name: string
  quantity: number
  completed: boolean
  category: string
}

export function ShoppingList() {
  const [items, setItems] = useState<ShoppingItem[]>([
    { id: '1', name: 'Lait', quantity: 2, completed: false, category: 'Frais' },
    { id: '2', name: 'Pain', quantity: 1, completed: true, category: 'Boulangerie' },
    { id: '3', name: 'Tomates', quantity: 1, completed: false, category: 'Légumes' },
    { id: '4', name: 'Riz', quantity: 1, completed: false, category: 'Épicerie' },
    { id: '5', name: 'Yaourts', quantity: 4, completed: false, category: 'Frais' },
  ])
  
  const [newItem, setNewItem] = useState('')

  const toggleItem = (id: string) => {
    setItems(items.map(item => 
      item.id === id ? { ...item, completed: !item.completed } : item
    ))
  }

  const addItem = () => {
    if (newItem.trim()) {
      setItems([
        ...items,
        {
          id: Date.now().toString(),
          name: newItem,
          quantity: 1,
          completed: false,
          category: 'Épicerie'
        }
      ])
      setNewItem('')
    }
  }

  const removeItem = (id: string) => {
    setItems(items.filter(item => item.id !== id))
  }

  const getCategoryColor = (category: string) => {
    switch (category.toLowerCase()) {
      case 'frais': return 'bg-blue-100 text-blue-800'
      case 'légumes': return 'bg-green-100 text-green-800'
      case 'boulangerie': return 'bg-orange-100 text-orange-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const remainingItems = items.filter(item => !item.completed).length

  return (
    <Card className="animate-scale-in">
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <ShoppingCart className="h-5 w-5 text-primary" />
            Liste de Courses
          </CardTitle>
          <Badge variant="outline">
            {remainingItems} restant{remainingItems > 1 ? 's' : ''}
          </Badge>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex gap-2">
          <Input
            placeholder="Ajouter un article..."
            value={newItem}
            onChange={(e) => setNewItem(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && addItem()}
            className="flex-1"
          />
          <Button onClick={addItem} size="icon" className="shrink-0">
            <Plus className="h-4 w-4" />
          </Button>
        </div>

        <div className="space-y-2 max-h-64 overflow-y-auto">
          {items.map((item) => (
            <div
              key={item.id}
              className={cn(
                "flex items-center gap-3 p-3 rounded-lg border transition-all duration-200 hover:shadow-md",
                item.completed && "opacity-60"
              )}
            >
              <button
                onClick={() => toggleItem(item.id)}
                className={cn(
                  "flex items-center justify-center w-5 h-5 rounded-full border-2 transition-colors",
                  item.completed
                    ? "bg-success border-success text-success-foreground"
                    : "border-border hover:border-primary"
                )}
              >
                {item.completed && <Check className="h-3 w-3" />}
              </button>
              
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <p className={cn(
                    "text-sm font-medium",
                    item.completed && "line-through text-muted-foreground"
                  )}>
                    {item.name}
                  </p>
                  {item.quantity > 1 && (
                    <Badge variant="secondary" className="text-xs">
                      x{item.quantity}
                    </Badge>
                  )}
                </div>
                <span className={cn(
                  "text-xs px-2 py-1 rounded-full",
                  getCategoryColor(item.category)
                )}>
                  {item.category}
                </span>
              </div>
              
              <Button
                variant="ghost"
                size="icon"
                onClick={() => removeItem(item.id)}
                className="h-8 w-8 text-muted-foreground hover:text-destructive"
              >
                <Trash2 className="h-4 w-4" />
              </Button>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}