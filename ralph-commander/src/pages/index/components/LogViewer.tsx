import React, { useRef, useEffect, useState } from 'react';
import { Terminal, Trash2, ArrowDown } from 'lucide-react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface LogViewerProps {
  logs: string;
  onClear: () => void;
}

export function LogViewer({ logs, onClear }: LogViewerProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [autoScroll, setAutoScroll] = useState(true);
  const [filter, setFilter] = useState<'all' | 'thoughts' | 'errors' | 'tools'>('all');

  useEffect(() => {
    if (autoScroll && containerRef.current) {
      containerRef.current.scrollTop = containerRef.current.scrollHeight;
    }
  }, [logs, autoScroll]);

  const filteredLogs = React.useMemo(() => {
    if (filter === 'all') return logs;
    // Basic line filtering logic
    const lines = logs.split('\n');
    if (filter === 'thoughts') return lines.filter(l => l.includes('Thought:') || l.includes('thinking')).join('\n');
    if (filter === 'errors') return lines.filter(l => l.toLowerCase().includes('error') || l.includes('fail')).join('\n');
    if (filter === 'tools') return lines.filter(l => l.includes('Executing tool:')).join('\n');
    return logs;
  }, [logs, filter]);

  return (
    <section className="bg-slate-900 rounded-[2.5rem] shadow-2xl overflow-hidden border-4 border-slate-800 flex flex-col h-full group">
      {/* Terminal Header */}
      <div className="bg-slate-800/50 backdrop-blur-md px-8 py-4 flex justify-between items-center border-b border-slate-700/50">
        <div className="flex items-center gap-4">
          <div className="flex gap-2">
            <div className="w-3 h-3 rounded-full bg-rose-500 shadow-[0_0_8px_rgba(244,63,94,0.4)]"></div>
            <div className="w-3 h-3 rounded-full bg-amber-500 shadow-[0_0_8px_rgba(245,158,11,0.4)]"></div>
            <div className="w-3 h-3 rounded-full bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.4)]"></div>
          </div>
          <div className="flex items-center gap-2 text-slate-400 font-black text-[10px] uppercase tracking-[0.2em] ml-2">
            <Terminal size={14} className="text-blue-400" />
            Live Transmission
          </div>
        </div>

        <div className="flex items-center gap-6">
          {/* Filters */}
          <div className="flex bg-slate-900/50 p-1 rounded-xl border border-white/5">
            {(['all', 'thoughts', 'errors', 'tools'] as const).map(f => (
              <button
                key={f}
                onClick={() => setFilter(f)}
                className={cn(
                  "px-3 py-1 rounded-lg text-[9px] font-black uppercase tracking-wider transition-all",
                  filter === f ? "bg-blue-600 text-white shadow-lg shadow-blue-500/20" : "text-slate-500 hover:text-slate-300"
                )}
              >
                {f}
              </button>
            ))}
          </div>

          <div className="h-4 w-px bg-slate-700"></div>

          <div className="flex items-center gap-4">
            <button
              onClick={() => setAutoScroll(!autoScroll)}
              className={cn(
                "flex items-center gap-2 text-[10px] font-black uppercase transition-colors",
                autoScroll ? "text-blue-400" : "text-slate-500 hover:text-slate-300"
              )}
            >
              <ArrowDown size={12} className={cn(autoScroll && "animate-bounce")} />
              Stick
            </button>
            <button
              onClick={onClear}
              className="p-2 text-slate-500 hover:text-rose-400 hover:bg-rose-500/10 rounded-xl transition-all"
              title="Clear Terminal"
            >
              <Trash2 size={14} />
            </button>
          </div>
        </div>
      </div>

      {/* Terminal Body */}
      <div 
        ref={containerRef}
        className="flex-1 p-8 overflow-auto font-mono text-sm leading-relaxed scrollbar-thin scrollbar-thumb-slate-700 scrollbar-track-transparent"
      >
        {filteredLogs ? (
          <pre className="text-emerald-400 whitespace-pre-wrap selection:bg-emerald-500/30">
            {filteredLogs}
            <span className="inline-block w-2 h-4 bg-emerald-500 animate-pulse ml-1 align-middle"></span>
          </pre>
        ) : (
          <div className="h-full flex flex-col items-center justify-center text-slate-700 space-y-4 opacity-50">
            <div className="w-12 h-12 border-2 border-slate-800 border-t-slate-600 rounded-full animate-spin"></div>
            <p className="font-black uppercase tracking-[0.3em] text-[10px]">Awaiting Uplink...</p>
          </div>
        )}
      </div>
    </section>
  );
}
