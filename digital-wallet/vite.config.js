import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import react from '@vitejs/plugin-react'; // <--- Make sure this line is present

export default defineConfig({
    plugins: [
        laravel({
            
            input: 'resources/js/react-app/src/main.jsx',
            refresh: true, 
        }),
        react(), 
    ],
    
    server: {
        hmr: {
            host: 'digital-wallet.test', 
            protocol: 'ws', 
        },
        host: true, 
        watch: {
            usePolling: true, 
        },
    },
});