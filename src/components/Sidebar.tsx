
import Link from 'next/link';
import Image from "next/image";
import style from './sidebar.module.css';
import { getProfile } from '@/app/lib/db/getProfile';
import { getFrendz } from '@/app/lib/db/getFrendz';

export default async function Sidebar() {
    const USER_NAME = "juanpe";
    const userProfile = await getProfile(USER_NAME);
    const userFrendz = await getFrendz(USER_NAME);
    
    return (
        <aside className={style.sidebar}>
            <nav className={style.frendz_list}>
                <li>
                    <Link className={style.profile_link} href={`/profile/${userProfile?.username}`}>
                        <Image
                            src={`/users/${userProfile?.profile_picture_url}`}
                            alt={`${userProfile?.first_name} ${userProfile?.last_name}`}
                            width={50}
                            height={50}
                            className="image-profile"
                        />
                        <span>Mi cuenta</span>
                    </Link>
                </li>
                <li className={style.frendz_title}>
                    <h3>Mis amigos</h3>
                </li>
                {userFrendz.map((friend) => (
                    <li key={friend.username}>
                        <Link className={style.frendz_item} href={`/profile/${friend.username}`}>
                            <span className={style.frendz_image}>
                                <Image
                                    src={`/users/${friend.profile_picture_url}`}
                                    alt={`${friend.display_name}`}
                                    width={50}
                                    height={50}
                                    className="image-profile"
                                />
                                <span className={`${style.frendz_status} ${(friend.account_status ? style.frendz_active : '')}`}></span>
                            </span>
                            <span>{
                                (friend.first_name || friend.last_name) ?
                                `${friend.first_name} ${friend.last_name}` :
                                friend.display_name}
                            </span>
                        </Link>
                    </li>
                ))}
            </nav>
        </aside>
    )
}