const jwt = require('jsonwebtoken');

// 模拟的 JWT_SECRET，与 auth.js 中的保持一致
// 实际应用中，应从环境变量读取
const JWT_SECRET = 'YOUR_JWT_SECRET'; 

module.exports = function(req, res, next) {
    // 从请求头中获取 token
    const token = req.header('x-auth-token'); // 或者 'Authorization': 'Bearer TOKEN'

    // 检查 token 是否存在
    if (!token) {
        return res.status(401).json({ message: '没有提供认证令牌，访问被拒绝' });
    }

    try {
        // 验证 token
        // 如果 token 是以 'Bearer ' 开头，需要先移除它
        let actualToken = token;
        if (token.startsWith('Bearer ')) {
            actualToken = token.substring(7, token.length);
        }
        
        const decoded = jwt.verify(actualToken, JWT_SECRET);
        req.user = decoded; // 将解码后的用户信息（例如 userId）附加到请求对象上
        next(); // 继续处理请求
    } catch (err) {
        res.status(401).json({ message: '认证令牌无效' });
    }
};