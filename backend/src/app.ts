import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import helmet  from 'helmet';
import { isTest } from '../env.ts';

const app = express();
// global middlewares 
app.use(helmet()); // handles security to prevent common vulnerabilities
app.use(morgan('combined', { skip: isTest() })); // morgan handles logging all api requestis in the browsers
app.use(cors({ origin: '*' })) // handle CORS : later we would configure it to only allow our app
app.use(express.json()); 
app.use(express.urlencoded({ extended: true })); // allows express to to decipher all url endcodings to unders and decode params

// api health-check endpoint 
app.use('/health', (req, res) => {
    res.status(200).json({
        status: "OK",
        timeStamp: new Date().toISOString(),
        service: "Health checker API "
    });
})

// importet routers go here 




export { app }; 
export default app; 