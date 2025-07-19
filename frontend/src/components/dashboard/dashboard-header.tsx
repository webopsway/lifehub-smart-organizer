import { Calendar, Bell, User } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

export function DashboardHeader() {
  const currentDate = new Date().toLocaleDateString('fr-FR', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })

  return (
    <header className="flex items-center justify-between p-6 border-b bg-gradient-primary text-primary-foreground animate-fade-in">
      <div className="flex flex-col space-y-1">
        <h1 className="text-3xl font-bold">LifeHub</h1>
        <p className="text-primary-foreground/80 capitalize">
          {currentDate}
        </p>
      </div>
      
      <div className="flex items-center space-x-4">
        <Button variant="secondary" size="icon" className="relative">
          <Bell className="h-4 w-4" />
          <span className="absolute -top-1 -right-1 h-3 w-3 bg-accent rounded-full text-[10px] flex items-center justify-center text-accent-foreground">
            2
          </span>
        </Button>
        
        <Avatar className="h-8 w-8">
          <AvatarImage src="/placeholder.svg" />
          <AvatarFallback>
            <User className="h-4 w-4" />
          </AvatarFallback>
        </Avatar>
      </div>
    </header>
  )
}