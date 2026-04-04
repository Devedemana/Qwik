import { server } from './app.ts'
import { env } from './../env.ts'

const PORT = env.PORT || 3000;
async function startServer() {
    try {
        server.listen(PORT, () => {
            console.log("Server is running on port: ", PORT);
        });
    } catch (_error: unknown) {
        console.log("App failed to start")
    }
}

// start server
startServer();