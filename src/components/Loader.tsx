import style from './loader.module.css';
import Image from 'next/image';

export default function Loader() {
    return (
        <section className={style.loading}>
            <figure>
                <Image
                    src="/loading_logo.png"
                    alt="Loading..."
                    width={74}
                    height={128}
                    className={style.loader}
                />
            </figure>
            <div className={style.loading_blur}></div>
        </section>
    )
}