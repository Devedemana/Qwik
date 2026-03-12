import type { Request, Response, NextFunction } from 'express';
import { ZodObject, ZodError, ZodType } from 'zod';

export const validateBody = (schema: ZodObject) => 
  async (req: Request, res: Response, next: NextFunction) => {
      try {
        // validate request body 
        const validatedBody = schema.safeParse(req.body); 
        // pass validate body to request
        req.body = validateBody; 

      // next middleware or function
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          status: 'error',
          details: error.issues.map((issue) => ({
                path: issue.path.join("."),
                detail:issue.message
          }))
        });
      }
      // other than that
          return res.status(500).json({
              status: 'error',
              message: 'Internal server error'
          });
       }
    };
  

 export const validateQuery = (schema: ZodObject) => 
  async (req: Request, res: Response, next: NextFunction) => {
      try {
        // validate request body 
        const validatedQuery = schema.safeParse(req.query); 
      // next middleware or function
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          status: 'error',
          details: error.issues.map((issue) => ({
                path: issue.path.join("."),
                detail:issue.message
          }))
        });
      }
      // other than that
          return res.status(500).json({
              status: 'error',
              message: 'Internal server error'
          });
    }
     };
  
     export const validateParams = (schema: ZodObject) => 
  async (req: Request, res: Response, next: NextFunction) => {
      try {
        // validate request body 
          const validatedParams = schema.safeParse(req.params); 
          
      // next middleware or function
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          status: 'error',
          details: error.issues.map((issue) => ({
                path: issue.path.join("."),
                detail:issue.message
          }))
        });
      }
      // other than that
     return res.status(500).json({
              status: 'error',
              message: 'Internal server error'
          });
    }
  };