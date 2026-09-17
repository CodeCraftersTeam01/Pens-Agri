const express = require('express');
const router = express.Router();
const Model_Forum = require('../../model/Model_Forum');

/**
 * GET /api/forum/posts
 * Retrieve inter-farmer community forum feed with attached standard verification checks
 */
router.get('/posts', async (req, res) => {
  try {
    const { limit = 50, offset = 0 } = req.query;
    const posts = await Model_Forum.getFeed(limit, offset);

    return res.status(200).json({
      status: true,
      message: 'Forum Komunitas Petani & Penyuluh Sumenep',
      total: posts.length,
      data: posts
    });
  } catch (error) {
    console.error('Error fetching forum posts:', error);
    return res.status(500).json({
      status: false,
      message: 'Gagal mengambil postingan forum',
      error: error.message
    });
  }
});

/**
 * POST /api/forum/posts
 * Create a new forum post with optional custom standard attached
 */
router.post('/posts', async (req, res) => {
  try {
    const { user_id, standar_id, title, body } = req.body;

    if (!user_id || !title || !body) {
      return res.status(400).json({
        status: false,
        message: 'Parameter wajib: user_id, title, body'
      });
    }

    const postData = {
      user_id: parseInt(user_id, 10),
      standar_id: standar_id ? parseInt(standar_id, 10) : null,
      title: title.trim(),
      body: body.trim()
    };

    const result = await Model_Forum.createPost(postData);
    const createdPost = await Model_Forum.getPostById(result.insertId);

    return res.status(201).json({
      status: true,
      message: 'Postingan forum berhasil dibuat',
      data: createdPost
    });

  } catch (error) {
    console.error('Error creating forum post:', error);
    return res.status(500).json({
      status: false,
      message: 'Gagal membuat postingan forum',
      error: error.message
    });
  }
});

/**
 * POST /api/forum/comments
 * Add a comment to a forum post
 */
router.post('/comments', async (req, res) => {
  try {
    const { post_id, user_id, comment } = req.body;

    if (!post_id || !user_id || !comment) {
      return res.status(400).json({
        status: false,
        message: 'Parameter wajib: post_id, user_id, comment'
      });
    }

    const commentData = {
      post_id: parseInt(post_id, 10),
      user_id: parseInt(user_id, 10),
      comment: comment.trim()
    };

    await Model_Forum.createComment(commentData);
    const updatedPost = await Model_Forum.getPostById(post_id);

    return res.status(201).json({
      status: true,
      message: 'Komentar berhasil ditambahkan',
      data: updatedPost
    });

  } catch (error) {
    console.error('Error adding forum comment:', error);
    return res.status(500).json({
      status: false,
      message: 'Gagal menambahkan komentar forum',
      error: error.message
    });
  }
});

/**
 * GET /api/forum/posts/:id
 * Retrieve single post details with full comment thread
 */
router.get('/posts/:id', async (req, res) => {
  try {
    const post = await Model_Forum.getPostById(req.params.id);
    if (!post) {
      return res.status(404).json({
        status: false,
        message: 'Postingan forum tidak ditemukan'
      });
    }

    return res.status(200).json({
      status: true,
      data: post
    });
  } catch (error) {
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
});

module.exports = router;
