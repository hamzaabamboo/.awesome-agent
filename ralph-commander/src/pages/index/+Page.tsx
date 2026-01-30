import React, { useEffect, useState } from 'react';

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
  const [lastRefreshed, setLastRefreshed] = useState<Date>(new Date());
  
  // Form State
  const [prompt, setPrompt] = useState('');
  const [maxIterations, setMaxIterations] = useState(20);
  const [completionPromise, setCompletionPromise] = useState('DONE');
  const [agent, setAgent] = useState('gemini');

  const fetchStatus = () => {
    fetch('/api/ralph/status')
      .then(res => res.json())
      .then(data => {
        setStatus(data);
        setLastRefreshed(new Date());
      })
      .catch(err => console.error(err));

    fetch('/api/ralph/logs')
      .then(res => res.text())
      .then(data => setLogs(data))
      .catch(err => console.error(err));
  };

  const handleStop = () => {
    if (!confirm('Are you sure you want to stop the autonomous loop?')) return;
    
    fetch('/api/ralph/stop', { method: 'POST' })
      .then(res => res.json())
      .then(data => {
        console.log(data);
        fetchStatus();
      })
      .catch(err => console.error(err));
  };

  const handleStart = (e: React.FormEvent) => {
    e.preventDefault();
    fetch('/api/ralph/start', { 
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt, max_iterations: maxIterations, completion_promise: completionPromise, agent })
    })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
            setPrompt('');
            fetchStatus();
        } else {
            alert('Failed to start: ' + data.error);
        }
      })
      .catch(err => console.error(err));
  };

  const handleClearLogs = () => {
    fetch('/api/ralph/logs/clear', { method: 'POST' })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
            setLogs('');
        }
      })
      .catch(err => console.error(err));
  };

  useEffect(() => {
    fetchStatus();
    const interval = setInterval(fetchStatus, 2000);
    return () => clearInterval(interval);
  }, []);

  if (!status) {
    return (
      <div className="min-h-screen flex items-center justify-center text-gray-500">
        Loading Ralph Status...
      </div>
    );
  }

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <header className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Ralph Commander</h1>
          <p className="text-gray-500 text-sm mt-1">Autonomous Agent Controller (Gemini Powered)</p>
        </div>
        <div className="flex items-center gap-4">
          {status.active && (
            <button 
              onClick={handleStop}
              className="bg-red-600 hover:bg-red-700 text-white font-bold py-2 px-4 rounded shadow transition-colors"
            >
              STOP LOOP
            </button>
          )}
          <div className="flex items-center gap-2">
            <span className={`w-3 h-3 rounded-full ${status.active ? 'bg-green-500 animate-pulse' : 'bg-red-500'}`}></span>
            <span className="font-medium text-gray-700">{status.active ? 'Active' : 'Idle'}</span>
          </div>
        </div>
      </header>

      {!status.active && (
          <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200 mb-8">
              <h2 className="text-xl font-bold mb-4">Start New Loop</h2>
              <form onSubmit={handleStart} className="space-y-4">
                  <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Task Prompt</label>
                      <textarea 
                          value={prompt}
                          onChange={(e) => setPrompt(e.target.value)}
                          className="w-full p-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500 h-24"
                          placeholder="Describe the task for the autonomous agent..."
                          required
                      />
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                      <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">Max Iterations</label>
                          <input 
                              type="number" 
                              value={maxIterations}
                              onChange={(e) => setMaxIterations(parseInt(e.target.value))}
                              className="w-full p-2 border border-gray-300 rounded-md"
                          />
                      </div>
                      <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">Completion Promise</label>
                          <input 
                              type="text" 
                              value={completionPromise}
                              onChange={(e) => setCompletionPromise(e.target.value)}
                              className="w-full p-2 border border-gray-300 rounded-md"
                          />
                      </div>
                      <div className="col-span-2">
                          <label className="block text-sm font-medium text-gray-700 mb-1">AI Agent</label>
                          <select
                              value={agent}
                              onChange={(e) => setAgent(e.target.value)}
                              className="w-full p-2 border border-gray-300 rounded-md bg-white"
                          >
                              <option value="gemini">Gemini (Default)</option>
                              <option value="claude">Claude</option>
                          </select>
                      </div>
                  </div>
                  <button type="submit" className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded shadow transition-colors">
                      Launch Agent
                  </button>
              </form>
          </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
          <h3 className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">Iteration</h3>
          <div className="flex items-end gap-2 mb-2">
            <span className="text-4xl font-bold text-blue-600">{status.iteration}</span>
            <span className="text-lg text-gray-400 font-normal mb-1">/ {status.max_iterations || '∞'}</span>
          </div>
          {status.max_iterations > 0 && (
            <div className="w-full bg-gray-200 rounded-full h-2.5">
              <div 
                className="bg-blue-600 h-2.5 rounded-full transition-all duration-500" 
                style={{ width: `${Math.min((status.iteration / status.max_iterations) * 100, 100)}%` }}
              ></div>
            </div>
          )}
        </div>
        
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200 col-span-2">
          <h3 className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">Completion Promise</h3>
          <div className="text-lg text-gray-800 font-medium">
            {status.completion_promise || <span className="text-gray-400 italic">No promise set</span>}
          </div>
        </div>
      </div>

      <div className="bg-gray-900 rounded-xl shadow-sm border border-gray-800 overflow-hidden mb-8">
        <div className="bg-gray-800 px-4 py-2 flex justify-between items-center">
          <h3 className="text-xs font-mono text-gray-400">Console Output (ralph-runner.log)</h3>
          <button 
            onClick={handleClearLogs}
            className="text-xs text-gray-400 hover:text-white bg-gray-700 hover:bg-gray-600 px-2 py-1 rounded transition-colors"
          >
            Clear Logs
          </button>
        </div>
        <pre className="p-4 text-xs font-mono text-green-400 h-64 overflow-y-auto whitespace-pre-wrap">
          {logs || "Waiting for logs..."}
        </pre>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden mb-8">
         <div className="bg-gray-50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
           <h3 className="font-semibold text-gray-700">Current Task Prompt</h3>
           <span className="text-xs text-gray-400">Started: {new Date(status.started_at).toLocaleString()}</span>
         </div>
         <div className="p-6 bg-slate-50 font-mono text-sm text-gray-600 whitespace-pre-wrap">
           {status.prompt}
         </div>
      </div>

      <div className="text-center text-xs text-gray-400 mb-4">
        Last updated: {lastRefreshed.toLocaleTimeString()}
      </div>

      <footer className="text-center text-gray-400 text-sm py-4 border-t border-gray-200 mt-auto">
        &copy; 2026 Ralph Commander (Vike+Gemini Edition). All rights reserved.
      </footer>
    </div>
  );
}