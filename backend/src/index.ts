import {app} from './app.ts'
import { env } from './../env.ts'
import { profileEnd } from 'console';


const PORT = env.PORT || 3000; 
async function startServer() {
    try {
        // background process like notifications: goes here 

        // start server 
        app.listen(env.PORT, () => {
            console.log("Server is running on port: ", PORT);
        }); 
        
    } catch (error: unknown) {
        console.log("App failed to start")
    }
}


// start server 
startServer(); 