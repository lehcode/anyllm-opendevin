import argparse
import uvicorn
# from opendevin.server import listen
import os
import agenthub  # noqa F401 (we import this to get the agents registered)

import debugpy

def parse_arguments():
    parser = argparse.ArgumentParser(description="Run Uvicorn server for OpenDevin app.")
    parser.add_argument("--port", type=int, default=3000, help="Port for the server")
    parser.add_argument("--reload", action="store_true", help="Enable auto-reloading of the server")
    parser.add_argument("--logging",  type=str, default="info", choices=["critical", "error", "warning", "info", "debug"], help="Log level for the server")
    return parser.parse_args()

if __name__ == "__main__":
    # Parse command-line arguments
    args = parse_arguments()

    debugpy.listen(("0.0.0.0", 5678))
    print("Python debugger is waiting for client to attach...")
    debugpy.wait_for_client()

    # Run Uvicorn server
    uvicorn.run("opendevin.server.listen:app",
        host="0.0.0.0",
        port=args.port,
        reload=args.reload,
        log_level=args.logging)
