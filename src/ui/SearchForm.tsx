'use client'

import styles from './searchForm.module.css';
import { MagnifyingGlassIcon } from '@heroicons/react/24/outline';

// TODO: Add a search form to search for users by name, username or email.

export default function SearchForm() {
    return (
        <form className={styles.form} action="">
            <section className={styles.search_container}>
                <input type="text" name="search" id="search" className={styles.search} placeholder='Buscar contacto' />
                <button type='submit' className={styles.icon}>
                    <MagnifyingGlassIcon />
                </button>
            </section>
        </form>
    )
}