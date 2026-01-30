import React from "react";
import "../renderer/index.css";

export default function LayoutDefault({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-slate-50">
      <main>{children}</main>
    </div>
  );
}
