import React, { useEffect, useState, useRef } from 'react';

interface RalphStatus {
  active: boolean;
  iteration: number;
  max_iterations: number;
  completion_promise: string;
  started_at: string;
  prompt: string;
}

export default function Page() {
  const [status, setStatus] = useState<RalphStatus | null>(null);
  const [logs, setLogs] = useState<string>('');
  
  const [prompt, setPrompt] = useState('');
  const [maxIterations, setMaxIterations] = useState(20);
  const [completionPromise, setCompletionPromise] = useState('DONE');
  const [agent, setAgent] = useState('gemini');

  const logContainerRef = useRef<HTMLDivElement>(null);
  const [autoScroll, setAutoScroll] = useState(true);

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
      body: JSON.stringify({ prompt, max_iterations: maxIterations, completion_promise: completionPromise, agent })
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
    fetchStatus();
    const interval = setInterval(fetchStatus, 3000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (autoScroll && logContainerRef.current) {
      logContainerRef.current.scrollTop = logContainerRef.current.scrollHeight;
    }
  }, [logs, autoScroll]);

  if (!status) return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 text-gray-500">
      Initializing Ralph Commander...
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-50 text-gray-900 font-sans py-10 px-4 sm:px-8">
      <div className="max-w-5xl mx-auto">
        
        {/* Header */}
        <header className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Ralph Commander</h1>
            <p className="text-gray-500 text-sm mt-1">Autonomous Loop Controller</p>
          </div>
          <div className="flex items-center gap-4">
            <div className={`flex items-center gap-2 px-3 py-1 rounded-full text-sm font-medium ${status.active ? 'bg-green-100 text-green-700' : 'bg-gray-200 text-gray-600'}`}>
              <span className={`w-2 h-2 rounded-full ${status.active ? 'bg-green-500 animate-pulse' : 'bg-gray-400'}`}></span>
              {status.active ? 'Active' : 'Idle'}
            </div>
            {status.active && (
              <button 
                onClick={handleStop} 
                className="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg font-medium transition shadow-sm hover:shadow-md active:transform active:scale-95"
              >
                STOP LOOP
              </button>
            )}
          </div>
        </header>

        {/* Start New Loop Form */}
        {!status.active && (
          <section className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-8 transition-all hover:shadow-md">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Start New Loop</h3>
            <form onSubmit={handleStart} className="space-y-4">
              <textarea 
                value={prompt} 
                onChange={e => setPrompt(e.target.value)} 
                placeholder="Describe the task for Ralph..." 
                required 
                className="w-full h-24 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none resize-none text-gray-700 placeholder-gray-400"
              />
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label className="block text-xs font-medium text-gray-500 mb-1 uppercase tracking-wide">Max Iterations</label>
                  <input 
                    type="number" 
                    value={maxIterations} 
                    onChange={e => setMaxIterations(parseInt(e.target.value))} 
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-gray-500 mb-1 uppercase tracking-wide">Agent</label>
                  <select 
                    value={agent} 
                    onChange={e => setAgent(e.target.value)} 
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none bg-white"
                  >
                    <option value="gemini">Gemini</option>
                    <option value="claude">Claude</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-medium text-gray-500 mb-1 uppercase tracking-wide">Action</label>
                  <button 
                    type="submit" 
                    className="w-full py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition shadow-sm"
                  >
                    Launch
                  </button>
                </div>
              </div>
            </form>
          </section>
        )}

        {/* Status Dashboard */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
            <label className="block text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Iteration Progress</label>
            <div className="flex items-baseline gap-2">
              <span className="text-4xl font-extrabold text-gray-900">{status.iteration}</span>
              <span className="text-xl text-gray-400 font-medium">/ {status.max_iterations}</span>
            </div>
            <div className="w-full bg-gray-100 rounded-full h-2 mt-4">
              <div 
                className="bg-blue-500 h-2 rounded-full transition-all duration-500" 
                style={{ width: `${Math.min((status.iteration / status.max_iterations) * 100, 100)}%` }}
              ></div>
            </div>
          </div>
          <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
            <label className="block text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Completion Promise</label>
            <div className="text-xl font-mono text-gray-800 bg-gray-50 p-3 rounded border border-gray-100 break-all">
              {status.completion_promise || 'None'}
            </div>
          </div>
        </div>

        {/* Terminal / Logs */}
        <section className="bg-gray-900 rounded-xl shadow-lg overflow-hidden border border-gray-800">
          <div className="bg-gray-800 px-4 py-2 flex justify-between items-center border-b border-gray-700">
            <div className="text-xs font-bold text-gray-400 uppercase tracking-wider flex items-center gap-2">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
              Live Logs
            </div>
            <div className="flex items-center gap-3">
              <label className="flex items-center gap-2 text-xs text-gray-400 cursor-pointer select-none">
                <input 
                  type="checkbox" 
                  checked={autoScroll} 
                  onChange={e => setAutoScroll(e.target.checked)} 
                  className="rounded bg-gray-700 border-gray-600 text-blue-500 focus:ring-0 focus:ring-offset-0"
                />
                Auto-scroll
              </label>
              <button 
                onClick={handleClearLogs}
                className="text-xs text-gray-400 hover:text-white px-2 py-1 hover:bg-gray-700 rounded transition"
              >
                Clear
              </button>
            </div>
          </div>
          <div 
            ref={logContainerRef}
            className="p-4 h-[500px] overflow-auto font-mono text-sm leading-relaxed"
          >
            {logs ? (
              <pre className="text-green-400 whitespace-pre-wrap">{logs}</pre>
            ) : (
              <div className="h-full flex flex-col items-center justify-center text-gray-600">
                <p>Waiting for activity...</p>
              </div>
            )}
          </div>
        </section>

      </div>
    </div>
  );
}