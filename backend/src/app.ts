import express from 'express';
import { createServer } from 'http';
import path from 'path';
import { fileURLToPath } from 'url';
import { initSocket } from './lib/index.ts';
import cors from 'cors';
import morgan from 'morgan';
import helmet  from 'helmet';
import { isTest } from '../env.ts';
import { merchantRouter, authRouter, orderRouter, cafeteriaRouter, userRouter, specialRouter } from './routes/index.ts';

const __dirname = path.dirname(fileURLToPath(import.meta.url));



const app = express()

// Serve static assets (images) — in production swap IMAGE_BASE_URL to your CDN
const publicDir = path.resolve(__dirname, '../../public');
app.use('/images', express.static(path.join(publicDir, 'images'), {
  maxAge: '7d',       // browser cache for 7 days
  immutable: false,   // allow updates without cache busting
  setHeaders: (res) => {
    res.setHeader('Cache-Control', 'public, max-age=604800');
  },
}));

// global middlewares
app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(morgan('combined', { skip: () => isTest() }));
app.use(cors({ origin: '*' })) // handle CORS : later we would configure it to only allow our app
app.use(express.json()); 
app.use(express.urlencoded({ extended: true })); // allows express to to decipher all url endcodings to unders and decode params

const httpServer = createServer(app); 
initSocket(httpServer); 

// api health-check endpoint 
app.use('/health', (_req, res) => {
    res.status(200).json({
        status: "OK",
        timeStamp: new Date().toISOString(),
            
        service: "Health checker API "
    });
})


// -------------------- ROUTES ----------------------------
app.use('/api/auth', authRouter);
app.use('/api/merchant', merchantRouter);
app.use('/api/orders', orderRouter);
app.use('/api/cafeterias', cafeteriaRouter);
app.use('/api/user', userRouter);
app.use('/api/specials', specialRouter);





export { app, httpServer as server }; 
export default app; 