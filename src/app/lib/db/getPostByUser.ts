import connectionPool from "@/app/lib/db";
import { UserPostByUser } from "@/app/types/types";

export const getPostByUser = async (id: string) => {
    let posts: UserPostByUser[] = [];

    try {
        const client = await connectionPool.connect();
        const result = await client.query(
            `SELECT 
                p.post_id,
                p.content,
                p.images,
                p.created_at,
                p.like_count,
                p.comment_count,
                u.username AS author_username,
                u.profile_picture_url AS author_avatar
            FROM public.posts p
            INNER JOIN public.users u 
                ON p.user_id = u.user_id
            WHERE u.username = '${id}'
            ORDER BY p.created_at DESC;`
        );
        client.release();

        posts = result.rows;
    } catch (error) {
        console.error("Error fetching data from database:", error);
        throw error;
    }

    return posts;
}