import express from 'express';
import { UserController } from '../controllers/user.controller';
import { verifyToken } from '../middleware/auth.middleware';

const router = express.Router();
const userController = new UserController();

// Public routes
router.post('/register', (req, res) => userController.register(req, res));
router.post('/login', (req, res) => userController.login(req, res));
router.post('/request-otp', (req, res) => userController.requestOTP(req, res));
router.post('/verify-otp', (req, res) => userController.verifyOTP(req, res));

// Protected routes
router.get('/profile', verifyToken, (req, res) => userController.getProfile(req, res));
router.put('/profile', verifyToken, (req, res) => userController.updateProfile(req, res));
router.put('/password', verifyToken, (req, res) => userController.updatePassword(req, res));
router.post('/logout', verifyToken, (req, res) => userController.logout(req, res));

// Role management routes
router.post('/roles', verifyToken, (req, res) => userController.createRole(req, res));
router.put('/roles/:roleId', verifyToken, (req, res) => userController.updateRole(req, res));
router.delete('/roles/:roleId', verifyToken, (req, res) => userController.deleteRole(req, res));
router.get('/roles', verifyToken, (req, res) => userController.getRoles(req, res));

export { router as userRoutes };