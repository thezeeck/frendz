import Image from "next/image";
import SearchForm from "@/ui/SearchForm";
import styles from "./header.module.css";

export default async function Header() {
    return (
        <header className={styles.header}>
            <Image
                src="/logo.png"
                alt="Logo"
                width={175}
                height={44}
            />
            <SearchForm />
        </header>
    )
}