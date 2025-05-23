const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs'); // bcryptjs 仍然需要用于比较密码，虽然哈希在模型层
const jwt = require('jsonwebtoken');
const authMiddleware = require('../middleware/authMiddleware');
const User = require('../models/User'); // 引入User模型

// JWT Secret - 强烈建议从环境变量中读取
const JWT_SECRET = process.env.JWT_SECRET || 'YOUR_JWT_SECRET_REPLACE_ME_AND_USE_ENV';

// 注册接口: POST /api/auth/register
router.post('/register', async (req, res) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({ message: '用户名和密码不能为空' });
        }
        // 密码长度校验也可以放在模型层，但这里也做一次明确校验
        if (password.length < 6) {
            return res.status(400).json({ message: '密码长度不能少于6位' });
        }

        let existingUser = await User.findOne({ username });
        if (existingUser) {
            return res.status(400).json({ message: '用户名已存在' });
        }

        // 创建新用户实例 (密码哈希将在UserSchema的pre-save钩子中自动处理)
        const newUser = new User({ username, password });
        await newUser.save(); // 保存到数据库

        // 为了安全，不直接返回密码等敏感信息
        // 可以考虑在注册成功后直接返回token让用户自动登录
        res.status(201).json({ 
            message: '用户注册成功', 
            user: {
                id: newUser._id, // 使用MongoDB的_id
                username: newUser.username 
            }
        });

    } catch (error) {
        console.error('Register error:', error);
        if (error.code === 11000) { // MongoDB duplicate key error for username
            return res.status(400).json({ message: '用户名已存在' });
        }
        // Mongoose validation error
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(val => val.message);
            return res.status(400).json({ message: messages.join(', ') });
        }
        res.status(500).json({ message: '服务器内部错误，注册失败' });
    }
});

// 登录接口: POST /api/auth/login
router.post('/login', async (req, res) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({ message: '用户名和密码不能为空' });
        }

        const user = await User.findOne({ username });
        if (!user) {
            return res.status(401).json({ message: '用户名或密码错误' }); // 使用401表示认证失败
        }

        // 使用User模型中定义的comparePassword方法
        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            return res.status(401).json({ message: '用户名或密码错误' }); // 使用401
        }

        const token = jwt.sign(
            { userId: user._id, username: user.username }, // payload
            JWT_SECRET,
            { expiresIn: '1h' } // Token有效期1小时，可根据需求调整
        );

        res.json({ 
            message: '登录成功', 
            token, 
            user: {
                id: user._id,
                username: user.username
            }
        });

    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: '服务器内部错误，登录失败' });
    }
});


// PUT /api/auth/me - 更新当前用户信息 (需要认证)
router.put('/me', authMiddleware, async (req, res) => {
    try {
        const currentUserId = req.user.userId; // 从JWT token中获取 (这是MongoDB的_id)
        const { username: newUsername, password: newPassword, currentPassword } = req.body;

        const userToUpdate = await User.findById(currentUserId);
        if (!userToUpdate) {
            // 此情况理论上不应发生，因为authMiddleware已验证用户存在
            return res.status(404).json({ message: '用户未找到' });
        }

        let updated = false;

        // 更新用户名
        if (newUsername && newUsername !== userToUpdate.username) {
            // 检查新用户名是否已被其他用户使用
            const existingUserWithNewName = await User.findOne({ username: newUsername, _id: { $ne: currentUserId } });
            if (existingUserWithNewName) {
                return res.status(400).json({ message: '新用户名已被其他用户使用' });
            }
            userToUpdate.username = newUsername;
            updated = true;
        }

        // 更新密码
        if (newPassword) {
            if (newPassword.length < 6) {
                 return res.status(400).json({ message: '新密码长度不能少于6位' });
            }
            // 验证当前密码 (如果用户已有密码且提供了currentPassword)
            // 如果用户是通过第三方登录首次设置密码，可能没有旧密码，此时不应要求currentPassword
            if (userToUpdate.password) { // 检查用户是否已经设置过密码
                if (!currentPassword) {
                    return res.status(400).json({ message: '请输入当前密码以修改新密码' });
                }
                const isMatch = await userToUpdate.comparePassword(currentPassword);
                if (!isMatch) {
                    return res.status(400).json({ message: '当前密码不正确' });
                }
            }
            // 如果userToUpdate.password为空 (例如，用户之前通过OAuth注册，现在想设置本地密码)
            // 则不需要currentPassword，可以直接设置新密码
            
            userToUpdate.password = newPassword; // Mongoose pre-save hook will hash it
            updated = true;
        }
        
        if (updated) {
            await userToUpdate.save(); // 保存到数据库
        }
        
        // 如果用户名更改，可能需要重新生成token，或通知前端更新本地存储的username
        // 为简单起见，这里仅返回成功消息和更新后的用户信息（不含密码）
        res.json({ 
            message: '用户信息更新成功', 
            user: { 
                id: userToUpdate._id, 
                username: userToUpdate.username 
            } 
        });

    } catch (error) {
        console.error('Update profile error:', error);
        if (error.code === 11000) { // MongoDB duplicate key error for username
            return res.status(400).json({ message: '新用户名已被使用' });
        }
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(val => val.message);
            return res.status(400).json({ message: messages.join(', ') });
        }
        res.status(500).json({ message: '服务器内部错误，更新失败' });
    }
});

// GET /api/auth/me - 获取当前用户信息 (需要认证)
router.get('/me', authMiddleware, async (req, res) => {
    try {
        const userId = req.user.userId; // 从JWT token中获取 (这是MongoDB的_id)

        const user = await User.findById(userId).select('-password'); // 查找用户，排除密码字段

        if (!user) {
            return res.status(404).json({ message: '用户未找到' });
        }

        res.json({
            message: '成功获取用户信息',
            user: {
                id: user._id,
                username: user.username,
                // 根据需要添加其他用户字段，例如 avatar, nickname, gender, phone
                avatar: user.avatar, // Assuming these fields exist on the User model
                nickname: user.nickname,
                gender: user.gender,
                phone: user.phone,
            }
        });

    } catch (error) {
        console.error('Error fetching user info:', error);
        res.status(500).json({ message: '服务器内部错误，获取用户信息失败' });
    }
});

module.exports = router;