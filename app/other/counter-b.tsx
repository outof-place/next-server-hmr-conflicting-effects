"use client";

import { useState } from "react";

export function CounterB() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(count - 1)}>B: {count}</button>;
}
