import connectionPool from "@/app/lib/db";
import { juanpeFrendz } from "./profile-placeholder";
import { UserFrendz } from "@/app/types/types";

const frendzListPlaceholder = {
    juanpe: juanpeFrendz,
}

export const getFrendz = async (id: keyof typeof frendzListPlaceholder) => {
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
        frendzList = frendzListPlaceholder[id]; // Fallback to placeholder data
        console.error("Error fetching data from database:", error);
        throw error;
    }

    return frendzList;
}