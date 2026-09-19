import { useSortable } from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";
import { motion } from "framer-motion";
import { Pencil, Trash2, GripVertical } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import type { Task } from "@/types/task";

interface TaskCardProps {
  task: Task;
  onEdit: () => void;
  onDelete: () => void;
  isOverlay?: boolean;
}

export function TaskCard({ task, onEdit, onDelete, isOverlay }: TaskCardProps) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({
    id: task.id,
    data: { task },
  });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <motion.div
      ref={setNodeRef}
      style={style}
      layout={!isDragging}
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: isDragging ? 0.4 : 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ duration: 0.18 }}
      className={cn(
        "group relative rounded-xl border border-border/60 bg-card p-3.5 shadow-card transition-shadow",
        !isOverlay && "hover:shadow-card-hover",
        isOverlay && "shadow-card-drag rotate-2 cursor-grabbing"
      )}
    >
      <div className="flex items-start gap-2">
        <button
          {...attributes}
          {...listeners}
          className="mt-0.5 shrink-0 cursor-grab touch-none text-muted-foreground/40 opacity-0 transition-opacity group-hover:opacity-100 active:cursor-grabbing"
          aria-label="Déplacer la tâche"
        >
          <GripVertical className="h-4 w-4" />
        </button>

        <div className="min-w-0 flex-1">
          <h3 className="text-sm font-medium leading-snug text-foreground">{task.title}</h3>
          {task.description && (
            <p className="mt-1 line-clamp-2 text-xs leading-relaxed text-muted-foreground">
              {task.description}
            </p>
          )}
        </div>
      </div>

      <div className="mt-2 flex items-center justify-between">
        <span className="text-[11px] text-muted-foreground/70">
          {new Date(task.updatedAt).toLocaleDateString("fr-FR", { day: "numeric", month: "short" })}
        </span>
        <div className="flex gap-0.5 opacity-0 transition-opacity group-hover:opacity-100">
          <Button variant="ghost" size="icon" className="h-7 w-7" onClick={onEdit} aria-label="Modifier">
            <Pencil className="h-3.5 w-3.5" />
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className="h-7 w-7 hover:text-destructive"
            onClick={onDelete}
            aria-label="Supprimer"
          >
            <Trash2 className="h-3.5 w-3.5" />
          </Button>
        </div>
      </div>
    </motion.div>
  );
}
