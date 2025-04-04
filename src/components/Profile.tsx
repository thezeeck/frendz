import { getProfile } from "@/app/lib/db/getProfile";
import Image from "next/image";
import style from "./profile.module.css";
import { MapPinIcon, CakeIcon, AtSymbolIcon, ChatBubbleLeftRightIcon, HandThumbUpIcon } from "@heroicons/react/24/outline";
import { getPostByUser } from "@/app/lib/db/getPostByUser";
import postStyle from "./posts.module.css";

export default async function Profile({ userId }: { userId: string }) {
    const userProfile = await getProfile(userId);
    const userPost = await getPostByUser(userId);

    if (!userProfile) {
        return (
            <section>
                <h1>Profile not found</h1>
                <p>The profile you are looking for does not exist.</p>
            </section>
        );
    }

    const UserPosts = ({ images }: { images: string[] }) => {
        return (
            <>
                {images.map((image, index) => (
                    <Image
                        key={index}
                        src={`/posts/${image}`}
                        alt={`Post image ${index + 1}`}
                        width={500}
                        height={500}
                        className={postStyle.post_image}
                    />
                ))}
            </>
        );
    };

    return (
        <section className={style.profile}>	
            <Image
                src={`/users/${userProfile.cover_photo_url}`}
                alt={userProfile.username}
                width={1000}
                height={400}
                className={style.cover_photo}
            />
            <Image
                src={`/users/${userProfile.profile_picture_url}`}
                alt={userProfile.username}
                width={250}
                height={250}
                className={style.profile_photo}
            />
            <header>
                <h1>{userProfile.first_name} {userProfile.last_name}</h1>
                <h2 className={style.username}>@{userProfile.username}</h2>
            </header>
            <p className={style.user_data}>
                <span className={style.user_data_item}>
                    <MapPinIcon />
                    {userProfile.current_city}
                </span>
                { userProfile.date_of_birth && (
                    <span className={style.user_data_item}>
                        <CakeIcon />
                        {userProfile.date_of_birth.toLocaleDateString('es-MX')}
                    </span>
                )}
                { userProfile.email && (
                    <span className={style.user_data_item}>
                        <AtSymbolIcon />
                        <a href={`mailto:${userProfile.email}`}>{userProfile.email}</a>
                    </span>
                )}
                { userProfile.website_url && (
                    <span className={style.user_data_item}>
                        <a href={userProfile.website_url} target="_blank" rel="noopener noreferrer">{userProfile.website_url}</a>
                    </span>
                )}
            </p>
            { userProfile.bio && (
                <blockquote className={style.bio}>
                    {userProfile.bio}
                </blockquote>
            )}
            <ul className={style.user_post_list}>
                {userPost.map((post) => (
                    <li className={postStyle.post} key={post.post_id}>
                        {post.content && (
                            <p className="post-content">{post.content}</p>
                        )}
                        {post.images && (<UserPosts images={post.images} />)}
                        <footer className={postStyle.post_footer}>
                            <button className={postStyle.post_footer_info}>
                                <ChatBubbleLeftRightIcon /> {post.comment_count}
                            </button>
                            <button className={postStyle.post_footer_info}>
                                <HandThumbUpIcon /> {post.like_count}
                            </button>
                        </footer>
                    </li>
                ))}
            </ul>
        </section>
    )
}