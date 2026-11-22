// A dynamic import in the client instrumentation file, the way an app defers a heavy SDK.
void import("./app/lazy").then((lazy) => lazy.init());
