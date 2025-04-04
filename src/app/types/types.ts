export interface UserProfile {
    user_id: string;
    username: string;
    email: string;
    first_name: string | null;
    last_name: string | null;
    display_name: string | null;
    date_of_birth: Date | null;
    profile_picture_url: string | null;
    cover_photo_url: string | null;
    bio: string | null;
    website_url: string | null;
    current_city: string | null;
    phone_number: string | null;
    created_at: Date | null;
    updated_at: Date | null;
    account_status: boolean;
}

export interface UserFrendz {
    username: string;
    display_name: string;
    profile_picture_url: string;
    first_name: string | null;
    last_name: string | null;
    account_status: boolean;
}

export interface UserPost {
    post_id: string;
    post_content: string | null;
    post_images: string[] | null;
    post_created: Date | null;
    post_privacy: string | null;
    like_count: number | null;
    comment_count: number | null;
    author_id: string;
    author_username: string;
    author_display_name: string | null;
    author_profile_picture: string | null;
    author_bio: string | null;
    author_website: string | null;
    author_city: string | null;
    author_phone: string | null;
    author_account_status: boolean;
}

export interface UserPostByUser {
    post_id: string;
    content: string | null;
    images: string[] | null;
    created_at: Date | null;
    like_count: number | null;
    comment_count: number | null;
    author_username: string;
    author_avatar: string | null;
}
