import Loader from "@/components/Loader";
import Profile from "@/components/Profile";
import { Suspense } from "react";

export default async function Page({ params }: { params: Promise<{ id: string }> }) {
    const { id } = await params;
    console.log("UserProfile component props:", id);
    return (
        <Suspense fallback={<Loader />}>

            <Profile userId={id} />
        </Suspense>
    )
}