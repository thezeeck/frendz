PGDMP                        }            postgres    17.4    17.4     J           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            K           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            L           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            M           1262    5    postgres    DATABASE     n   CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'es-MX';
    DROP DATABASE postgres;
                     postgres    false            N           0    0    DATABASE postgres    COMMENT     N   COMMENT ON DATABASE postgres IS 'default administrative connection database';
                        postgres    false    4941                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
                     pg_database_owner    false            O           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                        pg_database_owner    false    4            �            1255    32770 #   get_friend_posts(character varying)    FUNCTION     4  CREATE FUNCTION public.get_friend_posts(p_username character varying) RETURNS TABLE(post_id uuid, content text, images text[], created_at timestamp with time zone, author_username character varying, author_display_name character varying, author_avatar text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.post_id,
        p.content,
        p.images,
        p.created_at,
        u.username,
        u.display_name,
        u.profile_picture_url
    FROM public.posts p
    JOIN public.users u ON p.user_id = u.user_id
    WHERE 
        p.user_id IN (
            -- Obtener IDs de amigos
            SELECT 
                CASE 
                    WHEN ur.requester_id = target_user.user_id THEN ur.addressee_id
                    ELSE ur.requester_id
                END AS friend_id
            FROM public.user_relationships ur
            CROSS JOIN (
                SELECT user_id 
                FROM public.users 
                WHERE username = p_username
            ) AS target_user
            WHERE (ur.requester_id = target_user.user_id OR ur.addressee_id = target_user.user_id)
            AND ur.status = 'accepted'
        )
        AND p.privacy_settings IN ('public', 'friends') -- Solo posts visibles
    ORDER BY p.created_at DESC;
END;
$$;
 E   DROP FUNCTION public.get_friend_posts(p_username character varying);
       public               postgres    false    4            �            1259    24576    users    TABLE     �  CREATE TABLE public.users (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    display_name character varying(100),
    date_of_birth date,
    profile_picture_url text,
    cover_photo_url text,
    bio text,
    website_url character varying(255),
    current_city character varying(100),
    phone_number character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    account_status boolean DEFAULT false
);
    DROP TABLE public.users;
       public         heap r       postgres    false    4            �            1255    32769 *   get_friends_by_username(character varying)    FUNCTION       CREATE FUNCTION public.get_friends_by_username(p_username character varying) RETURNS SETOF public.users
    LANGUAGE plpgsql
    AS $$ -- <--- Declaración SETOF aquí
BEGIN
    RETURN QUERY
    SELECT u.*
    FROM public.users u
    WHERE u.user_id IN (
        SELECT 
            CASE
                WHEN ur.requester_id = target_user.user_id THEN ur.addressee_id
                ELSE ur.requester_id
            END AS friend_id
        FROM public.user_relationships ur
        CROSS JOIN (
            SELECT user_id 
            FROM public.users 
            WHERE username = p_username
        ) AS target_user
        WHERE (ur.requester_id = target_user.user_id OR ur.addressee_id = target_user.user_id)
        AND ur.status = 'accepted'
    );
END;
$$;
 L   DROP FUNCTION public.get_friends_by_username(p_username character varying);
       public               postgres    false    4    217            �            1255    32773 +   get_posts_with_user_info(character varying)    FUNCTION     �  CREATE FUNCTION public.get_posts_with_user_info(p_username character varying) RETURNS TABLE(post_id uuid, post_content text, post_images text[], post_created timestamp with time zone, post_privacy character varying, like_count integer, comment_count integer, author_id uuid, author_username character varying, author_display_name character varying, author_profile_picture text, author_bio text, author_website character varying, author_city character varying, author_phone character varying, author_account_status boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.post_id,
        p.content,
        p.images,
        p.created_at,
        p.privacy_settings,
        p.like_count,
        p.comment_count,
        
        u.user_id,
        u.username,
        u.display_name,
        u.profile_picture_url,
        u.bio,
        u.website_url,
        u.current_city,
        u.phone_number,
        u.account_status
    FROM public.posts p
    JOIN public.users u ON p.user_id = u.user_id
    WHERE 
        p.user_id IN (
            SELECT 
                CASE 
                    WHEN ur.requester_id = target_user.user_id THEN ur.addressee_id
                    ELSE ur.requester_id
                END
            FROM public.user_relationships ur
            CROSS JOIN (
                SELECT user_id 
                FROM public.users 
                WHERE username = p_username
            ) target_user
            WHERE (ur.requester_id = target_user.user_id OR ur.addressee_id = target_user.user_id)
            AND ur.status = 'accepted'
        )
        AND p.privacy_settings IN ('public', 'friends')
    ORDER BY p.created_at DESC;
END;
$$;
 M   DROP FUNCTION public.get_posts_with_user_info(p_username character varying);
       public               postgres    false    4            �            1259    24593    posts    TABLE     �  CREATE TABLE public.posts (
    post_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    content text,
    images text[],
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    privacy_settings character varying(20) DEFAULT 'public'::character varying,
    like_count integer DEFAULT 0,
    comment_count integer DEFAULT 0,
    is_deleted boolean DEFAULT false,
    CONSTRAINT posts_check CHECK (((content IS NOT NULL) OR (array_length(images, 1) IS NOT NULL))),
    CONSTRAINT posts_privacy_settings_check CHECK (((privacy_settings)::text = ANY ((ARRAY['public'::character varying, 'friends'::character varying, 'private'::character varying])::text[])))
);
    DROP TABLE public.posts;
       public         heap r       postgres    false    4            �            1259    24614    user_relationships    TABLE     �  CREATE TABLE public.user_relationships (
    relationship_id uuid DEFAULT gen_random_uuid() NOT NULL,
    requester_id uuid NOT NULL,
    addressee_id uuid NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_relationships_check CHECK ((requester_id <> addressee_id)),
    CONSTRAINT user_relationships_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'accepted'::character varying, 'blocked'::character varying])::text[])))
);
 &   DROP TABLE public.user_relationships;
       public         heap r       postgres    false    4            F          0    24593    posts 
   TABLE DATA           �   COPY public.posts (post_id, user_id, content, images, created_at, updated_at, privacy_settings, like_count, comment_count, is_deleted) FROM stdin;
    public               postgres    false    218   J4       G          0    24614    user_relationships 
   TABLE DATA           y   COPY public.user_relationships (relationship_id, requester_id, addressee_id, status, created_at, updated_at) FROM stdin;
    public               postgres    false    219   �6       E          0    24576    users 
   TABLE DATA           �   COPY public.users (user_id, username, email, first_name, last_name, display_name, date_of_birth, profile_picture_url, cover_photo_url, bio, website_url, current_city, phone_number, created_at, updated_at, account_status) FROM stdin;
    public               postgres    false    217   .<       �           2606    24608    posts posts_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (post_id);
 :   ALTER TABLE ONLY public.posts DROP CONSTRAINT posts_pkey;
       public                 postgres    false    218            �           2606    24624 *   user_relationships user_relationships_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.user_relationships
    ADD CONSTRAINT user_relationships_pkey PRIMARY KEY (relationship_id);
 T   ALTER TABLE ONLY public.user_relationships DROP CONSTRAINT user_relationships_pkey;
       public                 postgres    false    219            �           2606    24626 C   user_relationships user_relationships_requester_id_addressee_id_key 
   CONSTRAINT     �   ALTER TABLE ONLY public.user_relationships
    ADD CONSTRAINT user_relationships_requester_id_addressee_id_key UNIQUE (requester_id, addressee_id);
 m   ALTER TABLE ONLY public.user_relationships DROP CONSTRAINT user_relationships_requester_id_addressee_id_key;
       public                 postgres    false    219    219            �           2606    24590    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public                 postgres    false    217            �           2606    24592    users users_phone_number_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_number_key UNIQUE (phone_number);
 F   ALTER TABLE ONLY public.users DROP CONSTRAINT users_phone_number_key;
       public                 postgres    false    217            �           2606    24586    users users_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public                 postgres    false    217            �           2606    24588    users users_username_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_username_key;
       public                 postgres    false    217            �           2606    24609    posts posts_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;
 B   ALTER TABLE ONLY public.posts DROP CONSTRAINT posts_user_id_fkey;
       public               postgres    false    218    217    4776            �           2606    24632 7   user_relationships user_relationships_addressee_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_relationships
    ADD CONSTRAINT user_relationships_addressee_id_fkey FOREIGN KEY (addressee_id) REFERENCES public.users(user_id) ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.user_relationships DROP CONSTRAINT user_relationships_addressee_id_fkey;
       public               postgres    false    217    4776    219            �           2606    24627 7   user_relationships user_relationships_requester_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_relationships
    ADD CONSTRAINT user_relationships_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.users(user_id) ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.user_relationships DROP CONSTRAINT user_relationships_requester_id_fkey;
       public               postgres    false    219    4776    217            F   &  x���=rA���)ֹ[5=ӣ�������Q��%�J��\܀���� �.�#�*�Tj������=
>70�
�*�r�-�J1g��ɠ	�����	PY�ˬ���}����U�Wo�lW}�~���8�T�a�V���a;�t�]_uF�@�ޘ�23��t0���t�ˋ�tJ�6q��E ����b!�Ȁ�9J�Y������28]b4td���T}�M0�X{^���Ǵ|5,�����og�����Hg��L��r:h��8���$�,ȭf�[�]J��T*d��ȷr��T]ͺ���R�*5�Y�ߝ
q3�)y�1��y2=��Ѥ�$")��s�T�!;�Niݬ	)	;Y��.�
�6��X��ي�/��6m$e��׼����g��vL�!L~����d�=�\�O�_�(2��3}��AV|n'G�#X]r-�:0���7�x5��R�$aG�TU�Y��)�
��lA���3Ҩ�ަ~)�J��y�ͻq���K3����?|���<�!xr��snj�4�����z:�L~ ��
+      G   �  x���Kn,7E��Ud4HQ%�%Q��L2���[o�>T���jt��.�����R_ԃ�r�E-��bE\m���Ra��
�"Jc&�Xܲ/N6�c�}� ��)��U��s���1�\����#q*ę8��җ�ۧ2w�������T1oN�[ů�hT	2Y�Yr��?ċG�N��R�1�M|j�^�USۏ�3I�4έ�_����}�1;SѕP���l��Vm�̌��l1��ܪ����)����;�e;��>|�1�R.܍f 7w�Խ.ڡ�jE���0����7� ��U&�0�Q�����1����;�=�Y�GvC���ݬ��0�Vnd�4:��UT��̻�<Θ�RB-մ�7�A^:R�����ڵ�)��G�(���ςe�5b�U�λN�3p�{6�#ώF���IN���e�b��	���Q�9�ꨑ����78x-�D]Ҽ��h,��j�����0�&"92i5�c��(�M�A�)o��a6򞣔�o�Sf�ޓ��%�sQ��l<|��U�N��U;Y�н��ko��˕�N�9uH�hԴ���0g�lsl2��W새0�Q��n)=�1O�a*T:�"������=S��5}�������z��(ظ�H�i��J��M��\�ҡ�g�}����\?{���7�?^}� �=&��+zm:;d2�ܺv;�y��[�c�����3Ǩm�YB"w�{�ʏ�|�yct�
f׊;!ԖO�^�fu?c~��[�m�\�վ��m�
]^�� �,Ϗ�|/ϳ��j��F�9L�H2�8��3�Gz�ż ��P)D�</���&�0Dn~ه�x��[�:Ӭ
�v-غGu����V7�.c��=ߋ�P�$b���j�g�j��� "rv y���%���~e���FŒ�UG�� ��<\��#=�b�~�zn^�ז2�g�-	�e�1?��-��G-<U�8��o�@�Y�9J�3�Gz��<��1G��18㔂a�<S�{U������o1�X*������Ц�%w����q��HϷ����5)�_�΄^��^m��y��HϷ��/��J�]Od�X#I��KK�	����r�~��*�M�ԽL'C�W[I��b���3%n�7�~��
g�z�q��,�q���#�Z��8m�3懪����Mæ����'F�Ku\�>ky���RM0U`#��~�EEq6�a�۪������n0o��%�K�Yu.hv�{D�R�!�C��`�N7��B�#�y]w���+���t��Pu7�3���qe�:��쟳�u��g����a'C��E���Ҳm�>7x�a���Tg_R>1�\���?^}������y9�	���j���}w>��-f��`h��l��v=�+J���¸���q��3�m2�\f��AL���m��U�0��q��gs_8�Y��c�����^�|���6n1���z��/R�P      E   �  x��V�n�6]�_�f� LROz;�&HR#6�,(�jF�F(�������t�o��zɱ��ӠØ�吗G�K^e��ӊֲJhʕ��5��R��D�5�0����xP�^���4�֞�ڮ�L�ӏ�L� �L)�)O�#�~y����\h��������h[�XO��~ �_�g�2�U�Sd?E�E�fyQ��L�����L&e�9�9F��Ɏ{`���L�M3�P�EA�2���B2�+����b��Ժ�r��O}�<�N�3�+p�&���G���Ѧ7��\3n��ݨ��Hu&:z9@9�Ց�8����A(��~�
Q#/�uKha �7 I��""K��?0���
HX�dA�AxRY�TV9��$	K����"���f�]x���mf�j�JAK���v�pb$圲�6�� ��;�H[�W�n��v\��FϔW�Z7���:~��O�҆V9�iZ%�T��
�dj*��)H;uja�"<��0;�K�7ָ�-'�#k ���%e��6�%��`��S��aT�<�塵x����h��Ӏ�t�G5��G�͸�*_Ł/����G� �y�EQ��)�+YR2���VLM��Pi���.�U	����->X��2Ѝ�{�;@���-�gp�4�/l��R����Yd�gk��D��M���<d0D�Ќ`��n;���u�oL���s!D�$�Ĭ*�@��4�]7W��$�(���K���XNn"�#��V����
��_�艅;sʳ;���<���h��Ѹ��U#�-�Y�8���C��v��K�K~+�{"R�:�� �k*�~\IFaL%O�dd�\��64�n؎b�ƹ�(�"ϐ���q�BP��R�
�Ps���D�`���:��@�=o=לB����ӳH;P��C�v��qcB�X�q���߄B�^��I��$
I�\#�C
���E]IM�iQs����x蕆;�����NN}��U�Z��'|�N�<��c�����Ȝ�Ea�ή�S���}5fJ��úѦ��Q��f��Ep�S���qJ���b�TLPɅ�f_T^w��C��T�\�X�n�}�&�#^:�n�Փ�Z��M���I���X`��q��!�d�F4��~��:m�<y�������?~���U�_��ˀ_ٗt��� V�LؗnF_�Mi�U�)a]�7�b�FG��+�f��,����H�l3��Z�
��p��Z<V����߽�JDz����2w����u#��d��[�ՇyH��'�;w(oU�`��
�[ T�iU��F�e����<#)2��"��L��f��������}d��^�89v����p6�.(�\�d&w�[�g֭���z]�����r���r�m�E��~�:_u��#޶=��/߮��C�㽽�����     