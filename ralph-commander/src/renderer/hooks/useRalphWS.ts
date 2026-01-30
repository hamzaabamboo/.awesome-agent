import { useEffect, useState } from 'react';
import { useRalphStore } from '../store/useRalphStore';

export function useRalphWS() {
  const [connected, setWsConnected] = useState(false);
  const { setStatus, appendLogs, setLogs, setTasks } = useRalphStore();

  useEffect(() => {
    let socket: WebSocket;
    let reconnectTimer: any;

    const connect = () => {
      const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
      const host = window.location.host;
      socket = new WebSocket(`${protocol}//${host}/ws`);

      socket.onopen = () => {
        setWsConnected(true);
        console.log('📡 Ralph WS: Connected');
      };

      socket.onmessage = (event) => {
        try {
          const msg = JSON.parse(event.data);
          if (msg.type === 'status') {
            setStatus(msg.data);
          } else if (msg.type === 'logs') {
            appendLogs(msg.data);
          } else if (msg.type === 'tasks') {
            setTasks(msg.data);
          }
        } catch (e) {
          console.error('📡 Ralph WS: Error parsing message', e);
        }
      };

      socket.onclose = () => {
        setWsConnected(false);
        console.warn('📡 Ralph WS: Disconnected, retrying...');
        reconnectTimer = setTimeout(connect, 3000);
      };
    };

    connect();
    return () => {
      socket?.close();
      clearTimeout(reconnectTimer);
    };
  }, []);

  return { connected };
}