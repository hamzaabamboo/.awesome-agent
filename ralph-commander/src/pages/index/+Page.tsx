import React, { useEffect, useState, useRef } from 'react';
import { useRalphWS } from '../../renderer/hooks/useRalphWS';

interface RalphStatus {
  active: boolean;
  iteration: number;
  max_iterations: number;
  completion_promise: string;
  started_at: string;
  prompt: string;
  agent?: string;
  model?: string;
  queries?: number;
  phase?: string;
  stats?: any;
}

interface RalphTask {
  description: string;
  completed: boolean;
  phase?: string;
}

export default function Page() {
  const { connected, lastMessage } = useRalphWS();
  const [status, setStatus] = useState<RalphStatus | null>(null);
  const [logs, setLogs] = useState<string>('');
  const [tasks, setTasks] = useState<RalphTask[]>([]);
  const [changedFiles, setChangedFiles] = useState<{status: string, path: string}[]>([]);
  
  const [prompt, setPrompt] = useState('');
  const [maxIterations, setMaxIterations] = useState(20);
  const [completionPromise, setCompletionPromise] = useState('DONE');
  const [agent, setAgent] = useState('gemini');
  const [model, setModel] = useState('auto');
  const [availableModels, setAvailableModels] = useState<string[]>([]);
  
  const logContainerRef = useRef<HTMLDivElement>(null);
  const [autoScroll, setAutoScroll] = useState(true);

  const fetchModels = async () => {
    try {
      const res = await fetch('/api/agent/models');
      const data = await res.json();
      if (data.success && data.models.length > 0) {
        const aliases = ['auto', 'pro', 'flash', 'flash-lite'];
        const concrete = data.models.filter((m: string) => !aliases.includes(m));
        setAvailableModels(concrete);
      }
    } catch (err) {
      console.error('Failed to fetch models', err);
    }
  };

  const fetchStatus = async () => {
    try {
      const res = await fetch('/api/ralph/status');
      const data = await res.json();
      setStatus(data);
    } catch (err) {
      console.error('Status fetch failed', err);
    }

    try {
      const res = await fetch('/api/ralph/logs');
      const text = await res.text();
      setLogs(text);
    } catch (err) {
      console.error('Logs fetch failed', err);
    }

    try {
      const res = await fetch('/api/ralph/tasks');
      const data = await res.json();
      setTasks(data);
    } catch (err) {
      console.error('Tasks fetch failed', err);
    }

    try {
      const res = await fetch('/api/ralph/files');
      const data = await res.json();
      setChangedFiles(data);
    } catch (err) {
      console.error('Files fetch failed', err);
    }
  };

  const handleStop = async () => {
    if (!confirm('Stop loop?')) return;
    await fetch('/api/ralph/stop', { method: 'POST' });
    fetchStatus();
  };

  const handleStart = async (e: React.FormEvent) => {
    e.preventDefault();
    const res = await fetch('/api/ralph/start', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt, max_iterations: maxIterations, completion_promise: completionPromise, agent, model })
    });
    if (res.ok) {
      setPrompt('');
      fetchStatus();
    }
  };

  const handleClearLogs = async () => {
    await fetch('/api/ralph/logs', { method: 'DELETE' });
    setLogs('');
  };

  useEffect(() => {
    fetchModels();
    fetchStatus();
    const interval = setInterval(fetchStatus, 3000);
    return () => clearInterval(interval);
  }, []);

  // Handle incoming WS messages
  useEffect(() => {
    if (!lastMessage) return;
    
    if (lastMessage.type === 'status') {
      setStatus(lastMessage.data);
    } else if (lastMessage.type === 'logs') {
      setLogs(prev => prev + lastMessage.data);
    } else if (lastMessage.type === 'tasks') {
      setTasks(lastMessage.data);
    }
  }, [lastMessage]);

  useEffect(() => {
    if (autoScroll && logContainerRef.current) {
      logContainerRef.current.scrollTop = logContainerRef.current.scrollHeight;
    }
  }, [logs, autoScroll]);

  if (!status) return (
    <div className="min-h-screen flex items-center justify-center bg-[#f8fafc] text-slate-400 font-medium">
      <div className="flex flex-col items-center gap-4">
        <div className="w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
        Initializing Ralph Commander...
      </div>
    </div>
  );

  // Group tasks by phase
  const groupedTasks = tasks.reduce((acc, task) => {
    const phase = task.phase || "Uncategorized";
    if (!acc[phase]) acc[phase] = [];
    acc[phase].push(task);
    return acc;
  }, {} as Record<string, RalphTask[]>);

  return (
    <div className="min-h-screen bg-[#f1f5f9] text-slate-900 font-sans py-8 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        
        {/* Header */}
        <header className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-10">
          <div>
            <h1 className="text-4xl font-black text-slate-900 tracking-tight flex items-center gap-3">
              <span className="bg-gradient-to-br from-blue-600 to-indigo-700 text-white p-2 rounded-xl shadow-lg shadow-blue-200">RC</span>
              Ralph Commander
            </h1>
            <div className="flex items-center gap-4 mt-1">
              <p className="text-slate-500 font-medium">Autonomous Lifecycle Orchestrator</p>
              <div className={`flex items-center gap-1.5 px-2 py-0.5 rounded-md text-[10px] font-black uppercase tracking-wider ${connected ? 'bg-emerald-100 text-emerald-700' : 'bg-rose-100 text-rose-700'}`}>
                <span className={`w-1.5 h-1.5 rounded-full ${connected ? 'bg-emerald-500' : 'bg-rose-500'}`}></span>
                {connected ? 'Socket Live' : 'Socket Offline'}
              </div>
            </div>
          </div>
          <div className="flex items-center gap-3">
            {status.active && (
                <div className="px-4 py-1.5 bg-blue-600 text-white rounded-full text-xs font-black uppercase tracking-widest animate-pulse shadow-md shadow-blue-100 border border-blue-500">
                    Phase: {status.phase}
                </div>
            )}
            <div className={`flex items-center gap-2 px-4 py-1.5 rounded-full text-sm font-bold shadow-sm border ${status.active ? 'bg-emerald-50 text-green-700 border-emerald-100' : 'bg-slate-100 text-slate-500 border-slate-200'}`}>
              <span className={`w-2.5 h-2.5 rounded-full ${status.active ? 'bg-emerald-500 animate-pulse' : 'bg-slate-400'}`}></span>
              {status.active ? 'Agent Active' : 'Idle'}
            </div>
            {status.active && (
              <button 
                onClick={handleStop} 
                className="bg-rose-500 hover:bg-rose-600 text-white px-5 py-2 rounded-xl font-bold text-sm transition-all shadow-lg shadow-rose-100 hover:shadow-rose-200 active:scale-95"
              >
                TERMINATE
              </button>
            )}
          </div>
        </header>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
          
          {/* Left Column: Controls & Stats */}
          <div className="lg:col-span-8 space-y-8">
            
            {/* Start New Loop Form */}
            {!status.active && (
              <section className="bg-white rounded-3xl shadow-xl shadow-slate-200/50 border border-white p-8 transition-all hover:shadow-2xl hover:shadow-slate-200">
                <h3 className="text-xl font-black text-slate-800 mb-6 flex items-center gap-2">
                  <span className="w-8 h-8 bg-blue-50 text-blue-600 rounded-lg flex items-center justify-center text-base">🚀</span>
                  Deploy New Task
                </h3>
                <form onSubmit={handleStart} className="space-y-6">
                  <div className="relative group">
                    <textarea 
                      value={prompt} 
                      onChange={e => setPrompt(e.target.value)} 
                      placeholder="What should Ralph build today?" 
                      required 
                      className="w-full h-32 px-5 py-4 bg-slate-50 border-2 border-slate-100 rounded-2xl focus:border-blue-500 focus:bg-white transition-all outline-none resize-none text-slate-700 placeholder-slate-400 font-medium"
                    />
                  </div>
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div className="space-y-1.5">
                      <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Limit</label>
                      <input 
                        type="number" 
                        value={maxIterations} 
                        onChange={e => setMaxIterations(parseInt(e.target.value))} 
                        className="w-full px-4 py-3 bg-slate-50 border-2 border-slate-100 rounded-xl focus:border-blue-500 focus:bg-white outline-none font-bold text-slate-700"
                      />
                    </div>
                    <div className="space-y-1.5">
                      <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Engine</label>
                      <select 
                        value={agent} 
                        onChange={e => setAgent(e.target.value)} 
                        className="w-full px-4 py-3 bg-slate-50 border-2 border-slate-100 rounded-xl focus:border-blue-500 focus:bg-white outline-none bg-white font-bold text-slate-700"
                      >
                        <option value="gemini">Gemini CLI</option>
                        <option value="claude">Claude Code</option>
                      </select>
                    </div>
                    <div className="space-y-1.5">
                      <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Model</label>
                      <select 
                        value={model} 
                        onChange={e => setModel(e.target.value)} 
                        className="w-full px-4 py-3 bg-slate-50 border-2 border-slate-100 rounded-xl focus:border-blue-500 focus:bg-white outline-none bg-white font-bold text-slate-700"
                      >
                        <optgroup label="Standard Aliases">
                          <option value="auto">auto (Standard)</option>
                          <option value="pro">pro (Reasoning)</option>
                          <option value="flash">flash (Speed)</option>
                          <option value="flash-lite">flash-lite</option>
                        </optgroup>
                        {availableModels.length > 0 && (
                          <optgroup label="Concrete Models">
                            {availableModels.map(m => <option key={m} value={m}>{m}</option>)}
                          </optgroup>
                        )}
                      </select>
                    </div>
                  </div>
                  <button 
                    type="submit" 
                    className="w-full py-4 bg-gradient-to-r from-blue-600 to-indigo-700 hover:from-blue-700 hover:to-indigo-800 text-white rounded-2xl font-black text-lg transition-all shadow-xl shadow-blue-200 hover:shadow-blue-300 active:scale-[0.98]"
                  >
                    LAUNCH LIFECYCLE
                  </button>
                </form>
              </section>
            )}

            {/* Status Grid */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="bg-white p-5 rounded-3xl shadow-sm border border-slate-200">
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Turn</label>
                <div className="flex items-baseline gap-1.5">
                  <span className="text-3xl font-black text-slate-900">{status.iteration}</span>
                  <span className="text-sm text-slate-400 font-bold">/ {status.max_iterations}</span>
                </div>
                <div className="w-full bg-slate-100 rounded-full h-1.5 mt-3">
                  <div 
                    className="bg-blue-500 h-1.5 rounded-full transition-all duration-700 ease-out" 
                    style={{ width: `${Math.min((status.iteration / status.max_iterations) * 100, 100)}%` }}
                  ></div>
                </div>
              </div>
              <div className="bg-white p-5 rounded-3xl shadow-sm border border-slate-200">
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Queries</label>
                <div className="text-3xl font-black text-indigo-600">{status.queries || 0}</div>
              </div>
              <div className="bg-white p-5 rounded-3xl shadow-sm border border-slate-200 overflow-hidden">
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Model</label>
                <div className="text-xs font-black text-slate-700 truncate">{status.model || 'auto'}</div>
                <div className="text-[9px] text-slate-400 font-bold uppercase mt-1 truncate">{status.agent}</div>
              </div>
              <div className="bg-white p-5 rounded-3xl shadow-sm border border-slate-200 overflow-hidden">
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Promise</label>
                <div className="text-[10px] font-mono font-bold text-slate-500 bg-slate-50 p-1.5 rounded-lg border border-slate-100 truncate">
                  {status.completion_promise || 'null'}
                </div>
              </div>
            </div>

            {/* Detailed Stats */}
            {status.stats && Object.keys(status.stats).length > 0 && (
              <div className="bg-white/80 backdrop-blur-xl rounded-[2.5rem] shadow-2xl shadow-blue-100/50 border border-white p-8 mb-8">
                <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.3em] mb-8 flex items-center gap-3">
                  <span className="w-2 h-2 rounded-full bg-blue-500 shadow-[0_0_10px_rgba(59,130,246,0.5)]"></span>
                  Session Intelligence
                </h3>
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-12">
                  <div className="space-y-6">
                    <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest">Resource Allocation</label>
                    {Object.entries(status.stats.models || {}).map(([name, data]: [string, any]) => (
                      <div key={name} className="relative group">
                        <div className="text-[10px] font-black text-blue-600/70 mb-1.5 flex items-center gap-2">
                            <div className="w-1 h-3 bg-blue-500 rounded-full"></div>
                            {name}
                        </div>
                        <div className="flex justify-between items-end mb-2">
                          <span className="text-2xl font-black text-slate-800 tracking-tighter">{(data.tokens?.total || 0).toLocaleString()}</span>
                          <span className="text-[10px] font-bold text-slate-400 mb-1">TOKENS</span>
                        </div>
                        <div className="flex gap-2">
                            <div className="flex-1 h-1 bg-slate-100 rounded-full overflow-hidden">
                                <div className="h-full bg-indigo-500 rounded-full" style={{ width: `${Math.min(((data.tokens?.cached || 0) / (data.tokens?.total || 1)) * 100, 100)}%` }}></div>
                            </div>
                            <div className="text-[9px] font-black text-indigo-400 uppercase tracking-tighter whitespace-nowrap">
                                {Math.round(((data.tokens?.cached || 0) / (data.tokens?.total || 1)) * 100)}% Cache
                            </div>
                        </div>
                      </div>
                    ))}
                  </div>
                  
                  <div className="space-y-6 border-x border-slate-100 px-12">
                    <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest">Cognitive Load</label>
                    <div className="space-y-4">
                        <div className="flex justify-between items-center">
                            <span className="text-xs font-bold text-slate-500">Thought Stream</span>
                            <span className="font-mono text-xs font-black text-slate-800">
                                {Object.values(status.stats.models || {}).reduce((acc: number, m: any) => acc + (m.tokens?.thoughts || 0), 0).toLocaleString()}
                            </span>
                        </div>
                        <div className="flex justify-between items-center">
                            <span className="text-xs font-bold text-slate-500">Tool Operations</span>
                            <span className="font-mono text-xs font-black text-emerald-600">
                                {status.stats.tools?.totalCalls || 0}
                            </span>
                        </div>
                        <div className="flex justify-between items-center">
                            <span className="text-xs font-bold text-slate-500">Stability Index</span>
                            <span className="font-mono text-xs font-black text-blue-600">
                                {Math.round(((status.stats.tools?.totalSuccess || 0) / (status.stats.tools?.totalCalls || 1)) * 100)}%
                            </span>
                        </div>
                    </div>
                  </div>

                  <div className="flex flex-col justify-center">
                     <div className="bg-gradient-to-br from-slate-50 to-white p-6 rounded-3xl border border-slate-100 shadow-inner text-center">
                        <div className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-3">Neural Sync</div>
                        <div className="text-2xl font-black text-emerald-500 flex items-center justify-center gap-3">
                            <div className="relative flex h-4 w-4">
                            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                            <span className="relative inline-flex rounded-full h-4 w-4 bg-emerald-500"></span>
                            </div>
                            ONLINE
                        </div>
                        <p className="text-[9px] text-slate-400 mt-4 font-bold leading-relaxed px-4">
                            Agent is connected via high-speed IPC bridge.
                        </p>
                     </div>
                  </div>
                </div>
              </div>
            )}

            {/* Files Changed */}
            {changedFiles.length > 0 && (
              <div className="bg-white/50 backdrop-blur-sm rounded-[2rem] border border-white/50 p-6 mb-8">
                <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                    <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>
                    Work-in-Progress Assets
                </h3>
                <div className="flex flex-wrap gap-2">
                    {changedFiles.map((file, idx) => (
                        <div key={idx} className="px-3 py-1.5 bg-slate-800 text-white rounded-xl text-[10px] font-bold flex items-center gap-2 shadow-sm">
                            <span className={`w-1.5 h-1.5 rounded-full ${file.status === 'M' ? 'bg-amber-400' : 'bg-emerald-400'}`}></span>
                            <span className="opacity-50 font-black">{file.status}</span>
                            {file.path}
                        </div>
                    ))}
                </div>
              </div>
            )}

            {/* Terminal Output */}
            <section className="bg-slate-900 rounded-[2rem] shadow-2xl overflow-hidden border-4 border-slate-800">
              <div className="bg-slate-800/50 backdrop-blur-md px-6 py-3 flex justify-between items-center border-b border-slate-700">
                <div className="text-[10px] font-black text-slate-400 uppercase tracking-widest flex items-center gap-2">
                  <div className="flex gap-1.5">
                    <div className="w-2.5 h-2.5 rounded-full bg-rose-500/50"></div>
                    <div className="w-2.5 h-2.5 rounded-full bg-amber-500/50"></div>
                    <div className="w-2.5 h-2.5 rounded-full bg-emerald-500/50"></div>
                  </div>
                  <span className="ml-2">Live Output Stream</span>
                </div>
                <div className="flex items-center gap-4">
                  <label className="flex items-center gap-2 text-[10px] font-black text-slate-500 uppercase cursor-pointer select-none hover:text-slate-300 transition-colors">
                    <input 
                      type="checkbox" 
                      checked={autoScroll} 
                      onChange={e => setAutoScroll(e.target.checked)} 
                      className="w-3 h-3 rounded bg-slate-700 border-none text-blue-500 focus:ring-0 focus:ring-offset-0"
                    />
                    Scroll
                  </label>
                  <button 
                    onClick={handleClearLogs}
                    className="text-[10px] font-black text-slate-500 uppercase hover:text-white px-3 py-1 bg-slate-700/50 hover:bg-slate-700 rounded-lg transition-all"
                  >
                    Wipe
                  </button>
                </div>
              </div>
              <div 
                ref={logContainerRef}
                className="p-6 h-[600px] overflow-auto font-mono text-xs sm:text-sm leading-relaxed"
              >
                {logs ? (
                  <pre className="text-emerald-400 whitespace-pre-wrap selection:bg-emerald-500/30">{logs}</pre>
                ) : (
                  <div className="h-full flex flex-col items-center justify-center text-slate-700 gap-3">
                    <div className="w-10 h-10 border-2 border-slate-800 border-t-slate-600 rounded-full animate-spin"></div>
                    <p className="font-black uppercase tracking-widest text-[10px]">Listening for agent transmission...</p>
                  </div>
                )}
              </div>
            </section>
          </div>

          {/* Right Column: Task Plan */}
          <div className="lg:col-span-4 space-y-6">
            <section className="bg-white rounded-3xl shadow-lg shadow-slate-200/50 border border-white p-6 sticky top-8 max-h-[calc(100vh-4rem)] overflow-auto">
              <h3 className="text-lg font-black text-slate-800 mb-6 flex items-center gap-2">
                <span className="w-8 h-8 bg-purple-50 text-purple-600 rounded-lg flex items-center justify-center text-base">📋</span>
                Active Blueprint
              </h3>
              
              <div className="space-y-8">
                {Object.keys(groupedTasks).length > 0 ? Object.entries(groupedTasks).map(([phase, phaseTasks]) => (
                  <div key={phase} className="space-y-3">
                    <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] border-b border-slate-100 pb-2 mb-4">{phase}</h4>
                    <div className="space-y-2.5">
                      {phaseTasks.map((task, idx) => (
                        <div key={idx} className={`flex items-start gap-3 p-3 rounded-2xl border transition-all ${task.completed ? 'bg-emerald-50/50 border-emerald-100/50 opacity-60' : 'bg-slate-50/50 border-slate-100 hover:border-blue-200 group'}`}>
                          <div className={`mt-0.5 w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 border-2 transition-colors ${task.completed ? 'bg-emerald-500 border-emerald-500 text-white' : 'border-slate-300 group-hover:border-blue-400'}`}>
                            {task.completed && (
                              <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20"><path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd"></path></svg>
                            )}
                          </div>
                          <span className={`text-xs font-bold leading-relaxed ${task.completed ? 'text-slate-500 line-through' : 'text-slate-700'}`}>
                            {task.description}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>
                )) : (
                  <div className="py-10 text-center space-y-3">
                    <div className="text-4xl grayscale opacity-20">📭</div>
                    <p className="text-[10px] font-black text-slate-300 uppercase tracking-widest">No blueprint detected</p>
                  </div>
                )}
              </div>
            </section>
          </div>

        </div>

        {/* Footer */}
        <footer className="mt-12 pt-8 border-t border-slate-200 text-center">
          <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">
            &copy; 2026 Ralph Commander &bull; Autonomous Architecture System
          </p>
        </footer>

      </div>
    </div>
  );
}