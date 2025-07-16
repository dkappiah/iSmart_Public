import axios from 'axios';

const apiClient = axios.create({
    baseURL: 'http://digital-wallet.test/api', 
    withCredentials: true, 
    headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
    },
});


export const getCsrfToken = async () => {
    try {
        await axios.get('http://digital-wallet.test/sanctum/csrf-cookie', { withCredentials: true }); 
    } catch (error) {
        console.error("Failed to get CSRF cookie:", error);
        throw error; 
    }
};

export default apiClient;