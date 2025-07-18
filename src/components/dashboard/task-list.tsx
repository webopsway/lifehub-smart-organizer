import { useState } from "react"
import { Check, Plus, Star, Calendar } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { cn } from "@/lib/utils"

interface Task {
  id: string
  title: string
  completed: boolean
  priority: 'low' | 'medium' | 'high'
  dueDate?: string
}

export function TaskList() {
  const [tasks, setTasks] = useState<Task[]>([
    { id: '1', title: 'Appeler le médecin', completed: false, priority: 'high', dueDate: 'Aujourd\'hui' },
    { id: '2', title: 'Faire les courses', completed: false, priority: 'medium', dueDate: 'Demain' },
    { id: '3', title: 'Répondre aux emails', completed: true, priority: 'medium' },
    { id: '4', title: 'Préparer présentation', completed: false, priority: 'high', dueDate: 'Vendredi' },
    { id: '5', title: 'Sortir les poubelles', completed: true, priority: 'low' },
  ])
  
  const [newTask, setNewTask] = useState('')

  const toggleTask = (id: string) => {
    setTasks(tasks.map(task => 
      task.id === id ? { ...task, completed: !task.completed } : task
    ))
  }

  const addTask = () => {
    if (newTask.trim()) {
      setTasks([
        ...tasks,
        {
          id: Date.now().toString(),
          title: newTask,
          completed: false,
          priority: 'medium'
        }
      ])
      setNewTask('')
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high': return 'destructive'
      case 'medium': return 'warning'
      case 'low': return 'secondary'
      default: return 'secondary'
    }
  }

  const completedTasks = tasks.filter(task => task.completed).length
  const totalTasks = tasks.length

  return (
    <Card className="animate-scale-in">
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <Check className="h-5 w-5 text-primary" />
            Mes Tâches
          </CardTitle>
          <Badge variant="outline">
            {completedTasks}/{totalTasks}
          </Badge>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex gap-2">
          <Input
            placeholder="Ajouter une nouvelle tâche..."
            value={newTask}
            onChange={(e) => setNewTask(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && addTask()}
            className="flex-1"
          />
          <Button onClick={addTask} size="icon" className="shrink-0">
            <Plus className="h-4 w-4" />
          </Button>
        </div>

        <div className="space-y-2 max-h-64 overflow-y-auto">
          {tasks.map((task) => (
            <div
              key={task.id}
              className={cn(
                "flex items-center gap-3 p-3 rounded-lg border transition-all duration-200 hover:shadow-md",
                task.completed && "opacity-60"
              )}
            >
              <button
                onClick={() => toggleTask(task.id)}
                className={cn(
                  "flex items-center justify-center w-5 h-5 rounded-full border-2 transition-colors",
                  task.completed
                    ? "bg-success border-success text-success-foreground"
                    : "border-border hover:border-primary"
                )}
              >
                {task.completed && <Check className="h-3 w-3" />}
              </button>
              
              <div className="flex-1 min-w-0">
                <p className={cn(
                  "text-sm font-medium",
                  task.completed && "line-through text-muted-foreground"
                )}>
                  {task.title}
                </p>
                {task.dueDate && (
                  <div className="flex items-center gap-1 mt-1">
                    <Calendar className="h-3 w-3 text-muted-foreground" />
                    <span className="text-xs text-muted-foreground">{task.dueDate}</span>
                  </div>
                )}
              </div>
              
              <Badge variant={getPriorityColor(task.priority) as any} className="text-xs">
                {task.priority === 'high' && <Star className="h-3 w-3 mr-1" />}
                {task.priority === 'high' ? 'Urgent' : 
                 task.priority === 'medium' ? 'Normal' : 'Faible'}
              </Badge>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}