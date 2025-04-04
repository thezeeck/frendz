import { getPost } from "@/app/lib/db/getPost";
import Image from "next/image";
import style from "./posts.module.css";
import { ChatBubbleLeftRightIcon, HandThumbUpIcon } from '@heroicons/react/24/outline';

export default async function Posts() {
    const USER_NAME = "juanpe";
    const posts = await getPost(USER_NAME, 0);
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
                        className={style.post_image}
                    />
                ))}
            </>
        );
    };

    return (
        <main className={style.post_list}>
            {posts.map((post) => (
                <article key={post.post_id} className={style.post}>
                    <header className={style.post_header}>
                        <Image
                            src={`/users/${post.author_profile_picture}`}
                            alt={post.author_username}
                            width={50}
                            height={50}
                            className="image-profile"
                        />
                        <h3>{post.author_display_name}</h3>
                    </header>
                    {post.post_content && (
                        <p className="post-content">{post.post_content}</p>
                    )}
                    {post.post_images && (<UserPosts images={post.post_images} />)}
                    <footer className={style.post_footer}>
                        <button className={style.post_footer_info}>
                            <ChatBubbleLeftRightIcon /> {post.comment_count}
                        </button>
                        <button className={style.post_footer_info}>
                            <HandThumbUpIcon /> {post.like_count}
                        </button>
                    </footer>
                </article>
            ))}
        </main>
    );
}