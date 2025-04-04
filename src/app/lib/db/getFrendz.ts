import connectionPool from "@/app/lib/db";
import { UserFrendz } from "@/app/types/types";


export const getFrendz = async (id: string) => {
    let frendzList: UserFrendz[] = [];

    try {
        const client = await connectionPool.connect();
        const result = await client.query(`SELECT 
            username,
            display_name,
            profile_picture_url,
            first_name,
            last_name,
            account_status
            FROM get_friends_by_username('${id}');`);
        client.release();

        frendzList = result.rows;
    } catch (error) {
        console.error("Error fetching data from database:", error);
        throw error;
    }

    return frendzList;
}