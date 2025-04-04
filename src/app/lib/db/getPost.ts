import connectionPool from "@/app/lib/db";
import { UserPost } from "@/app/types/types";

export const getPost = async (id: string, offset: number = 0) => {
    let post: UserPost[] = [];

    try {
        const client = await connectionPool.connect();
        const result = await client.query(`SELECT * 
            FROM get_posts_with_user_info('${id}')
            LIMIT 10 OFFSET ${offset};`);
        client.release();

        post = result.rows;
    } catch (error) {
        console.error("Error fetching data from database:", error);
        throw error;
    }

    return post;
} 