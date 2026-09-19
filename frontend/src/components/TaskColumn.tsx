import { useDroppable } from "@dnd-kit/core";
import { SortableContext, verticalListSortingStrategy } from "@dnd-kit/sortable";
import { AnimatePresence } from "framer-motion";
import { cn } from "@/lib/utils";
import { TaskCard } from "@/components/TaskCard";
import type { Task, TaskStatus } from "@/types/task";

const COLUMN_META: Record<TaskStatus, { label: string; dot: string; bg: string; ring: string }> = {
  TODO: { label: "À faire", dot: "bg-status-todo", bg: "bg-status-todo-bg", ring: "ring-status-todo/30" },
  IN_PROGRESS: {
    label: "En cours",
    dot: "bg-status-progress",
    bg: "bg-status-progress-bg",
    ring: "ring-status-progress/30",
  },
  DONE: { label: "Terminée", dot: "bg-status-done", bg: "bg-status-done-bg", ring: "ring-status-done/30" },
};

interface TaskColumnProps {
  status: TaskStatus;
  tasks: Task[];
  onEdit: (task: Task) => void;
  onDelete: (task: Task) => void;
}

export function TaskColumn({ status, tasks, onEdit, onDelete }: TaskColumnProps) {
  const meta = COLUMN_META[status];
  const { setNodeRef, isOver } = useDroppable({ id: status, data: { status } });

  return (
    <div className="flex min-w-[280px] flex-1 flex-col">
      <div className="mb-3 flex items-center gap-2 px-1">
        <span className={cn("h-2 w-2 rounded-full", meta.dot)} />
        <h2 className="text-sm font-semibold text-foreground">{meta.label}</h2>
        <span className="ml-auto rounded-full bg-muted px-2 py-0.5 text-xs font-medium text-muted-foreground">
          {tasks.length}
        </span>
      </div>

      <div
        ref={setNodeRef}
        className={cn(
          "flex min-h-[200px] flex-1 flex-col gap-2 rounded-2xl border-2 border-dashed border-transparent p-2 transition-colors",
          meta.bg,
          isOver && cn("border-current ring-2", meta.ring)
        )}
      >
        <SortableContext items={tasks.map((t) => t.id)} strategy={verticalListSortingStrategy}>
          <AnimatePresence mode="popLayout">
            {tasks.map((task) => (
              <TaskCard key={task.id} task={task} onEdit={() => onEdit(task)} onDelete={() => onDelete(task)} />
            ))}
          </AnimatePresence>
        </SortableContext>

        {tasks.length === 0 && (
          <div className="flex flex-1 items-center justify-center rounded-xl py-8 text-center text-xs text-muted-foreground/60">
            Dépose une tâche ici
          </div>
        )}
      </div>
    </div>
  );
}
