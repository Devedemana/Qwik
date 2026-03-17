import express from 'express';
import { createServer } from 'http'; 
import { initSocket } from './lib/index.ts';
import cors from 'cors';
import morgan from 'morgan';
import helmet  from 'helmet';
import { isTest } from '../env.ts';
import { merchantRouter, authRouter, cafeteriaRouter } from './routes/index.ts';
import { errorHandler } from 'middlewares/error.middleware.ts';
import { notFoundError } from 'middlewares/error.middleware.ts';



const app = express()
// global middlewares 
app.use(helmet()); 
app.use(morgan('combined', { skip: function(){  isTest()} }));
app.use(cors({ origin: '*' })) 
app.use(express.json()); 
app.use(express.urlencoded({ extended: true })); // allows express to to decipher all url endcodings to unders and decode params

const httpServer = createServer(app); 
initSocket(httpServer); 

// api health-check endpoint 
app.use('/health', (req, res) => {
    res.status(200).json({
        status: "OK",
        timeStamp: new Date().toISOString(),
            
        service: "Health checker API "
    });
})


// -------------------- ROUTES ----------------------------
app.use('/api/merchant', merchantRouter) ; 
app.use('/api/auth', authRouter); 
app.use('/api/cafeterias', cafeteriaRouter); 


// error handlers
app.use(errorHandler);
app.use(notFoundError);

export { app, httpServer as server }; 
export default app; 