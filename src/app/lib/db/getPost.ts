import connectionPool from "@/app/lib/db";
import { UserPost } from "@/app/types/types";
import { juanpeFrendzPosts } from "./profile-placeholder";

const postsPlaceholder = {
    juanpe: juanpeFrendzPosts,
}

export const getPost = async (id: keyof typeof postsPlaceholder, offset: number = 0) => {
    let post: UserPost[] = [];

    try {
        const client = await connectionPool.connect();
        const result = await client.query(`SELECT * 
            FROM get_posts_with_user_info('${id}')
            LIMIT 10 OFFSET ${offset};`);
        client.release();

        post = result.rows;
    } catch (error) {
        post = postsPlaceholder[id]; // Fallback to placeholder data
        console.error("Error fetching data from database:", error);
        throw error;
    }

    return post;
} 