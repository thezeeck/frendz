import { UserProfile } from "@/app/types/types";
import connectionPool from "@/app/lib/db";

export const getProfile = async (id: string) => {
    let userProfile: UserProfile | null = null;

    try {
        const client = await connectionPool.connect();
        const result = await client.query(`SELECT * FROM public.users where username = '${id}'`);
        client.release();

        userProfile = result.rows[0];
    } catch (error) {
        console.error("Error fetching data from database:", error);
        throw error;
    }

    return userProfile;
}