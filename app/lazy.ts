// The lazily loaded module shares a dependency (react) with the client entry and with the
// client components of every page. Without this import the error does not appear.
import { version } from "react";

export function init() {
  console.log("lazy module loaded, react", version);
}
