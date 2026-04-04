import { Server } from 'socket.io';
import type { Server as HttpServer } from 'http';

let io: Server;

export const initSocket = (server: HttpServer) => {
  io = new Server(server, {
    cors: { origin: '*' },
    transports: ['polling', 'websocket'],
  });

  io.on('connection', (socket) => {
    socket.on('join_cafeteria', (cafeteriaId) => {
      socket.join(`cafeteria:${cafeteriaId}`);
    });
    // User joins their own room to receive order status push events
    socket.on('join_user', (userId: string) => {
      socket.join(`user:${userId}`);
    });
  });

  // return io;
};

export const emitUpdate = (room: string, event: string, data: any) => {
  if (io) {
    io.to(room).emit(event, data);
  }
};


