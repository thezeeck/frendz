import { Suspense } from "react";
import Loader from "@/components/Loader";
import Posts from "@/components/Posts";

export default async function Home() {
  return (
    <Suspense fallback={<Loader />}>
      <Posts />
    </Suspense>
  );
}
