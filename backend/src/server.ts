import dotenv from 'dotenv';
import app from './app';
import { connectRabbitMQ, closeRabbitMQ } from './lib/rabbitmq';
import { startConsumers } from './lib/consumers';

dotenv.config();

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    await connectRabbitMQ();
    await startConsumers();

    app.listen(PORT, () => {
      console.log(`----- Server started on http://localhost:${PORT} -----`);
    });

    process.on('SIGINT', async () => {
      console.log('\n----- Encerrando servidor... -----');
      await closeRabbitMQ();
      process.exit(0);
    });
  } catch (error) {
    console.error('----- Erro ao iniciar servidor:', error, " -----");
    process.exit(1);
  }
}

startServer();