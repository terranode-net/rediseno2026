// Contenido legal — textos oficiales de Terranode S.A.S.
// Las versiones ES y EN tienen exactamente las mismas secciones y contenido.

export interface LegalSection { id: string; title: string; content: string }
export interface SummaryCard { icon: string; color: string; title: string; desc: string }

export const UPDATED_ES = '20 de Marzo de 2026';
export const UPDATED_EN = 'March 20, 2026';

// ══════════════════ TÉRMINOS Y CONDICIONES ══════════════════
export const TERMS_ES: LegalSection[] = [
  { id: 'aceptacion', title: '1. Aceptación de los Términos', content: `Al acceder, registrarse o utilizar cualquier servicio ofrecido por Terranode ("la Compañía", "nosotros", "nuestro"), usted ("el Cliente") acepta estar sujeto a estos Términos y Condiciones de manera incondicional. Si no está de acuerdo con alguna parte de estos términos, no podrá utilizar nuestros servicios.

Estos términos constituyen un acuerdo legalmente vinculante entre usted y Terranode, y se rigen por las leyes vigentes de la República del Ecuador. Terranode se reserva el derecho de modificar estos términos en cualquier momento mediante aviso publicado en este sitio web. El uso continuado del servicio tras dichos cambios constituirá su aceptación de los nuevos términos.` },
  { id: 'servicios', title: '2. Descripción de los Servicios', content: `Terranode ofrece servicios de infraestructura en la nube que incluyen, sin limitación: alojamiento web compartido (Web Hosting), servidores privados virtuales (VPS), servidores dedicados, correo corporativo (TerraMail), Microsoft 365, desarrollo web y desarrollo de sistemas.

Los servicios se activan tras la confirmación del pago. Nos reservamos el derecho de modificar, suspender o discontinuar cualquier servicio con notificación previa razonable al cliente, excepto en casos de violaciones a estas políticas donde la suspensión puede ser inmediata.` },
  { id: 'cuentas', title: '3. Cuentas y Responsabilidades del Cliente', content: `3.1 **Información Veraz.** El cliente se compromete a proporcionar información veraz, exacta, actualizada y completa durante el proceso de registro y a mantenerla actualizada.

3.2 **Seguridad de la Cuenta.** El cliente es el único responsable de mantener la confidencialidad de sus credenciales de acceso y de todas las actividades que se realicen bajo su cuenta. Terranode no será responsable por pérdidas ocasionadas por el uso no autorizado de su cuenta.

3.3 **Uso Adecuado.** El cliente es responsable de garantizar que el uso de los servicios cumpla con todas las leyes locales, nacionales e internacionales aplicables, así como con las presentes políticas.

3.4 **Contacto.** El cliente debe mantener una dirección de correo electrónico activa y válida para recibir comunicaciones importantes sobre su cuenta y los servicios.` },
  { id: 'pagos', title: '4. Pagos, Facturación y Renovaciones', content: `4.1 **Precios.** Todos los precios se expresan en dólares estadounidenses (USD) salvo indicación contraria. Los precios pueden estar sujetos a impuestos aplicables según la legislación ecuatoriana.

4.2 **Facturación.** Los servicios se facturan de manera anticipada según el ciclo de facturación seleccionado (mensual, anual u otro). La falta de pago en la fecha de vencimiento puede resultar en la suspensión del servicio sin previo aviso adicional.

4.3 **Renovaciones.** Los servicios se renuevan automáticamente al final de cada ciclo de facturación, salvo que el cliente cancele con al menos 24 horas de anticipación a la fecha de renovación.

4.4 **Suspensión por Falta de Pago.** Los servicios no pagados en su fecha de vencimiento serán suspendidos. Los datos podrán ser eliminados de forma permanente después de 15 días de vencimiento sin pago, y Terranode no se hace responsable por la pérdida de datos en este caso.

4.5 **Destrucción de Servidores VPS y Dedicados.** En los servicios de VPS y Servidores Dedicados, una vez que el servicio sea cancelado, suspendido por falta de pago, o terminado por violación de políticas, el servidor se destruirá de forma inmediata e irreversible junto con todos los datos, snapshots, backups internos y configuraciones almacenadas en él. Terranode no conservará ninguna copia de los datos ni tendrá la capacidad de recuperarlos una vez ejecutada la destrucción. El cliente es el único responsable de exportar y respaldar toda su información antes de la cancelación o ante cualquier evento que pudiera derivar en la terminación del servicio.

4.6 **Contracargos.** Si un cliente inicia un contracargo o disputa ante su institución financiera, Terranode se reserva el derecho de suspender inmediatamente todos los servicios, compartir información relevante con el procesador de pagos para impugnar el contracargo, y aplicar una tarifa administrativa. La iniciación de un contracargo renuncia automáticamente al derecho a reembolso bajo nuestra política.` },
  { id: 'uso-aceptable', title: '5. Política de Uso Aceptable', content: `5.1 **Actividades Prohibidas.** El cliente no podrá usar los servicios de Terranode para:
- Enviar correo no solicitado (SPAM), phishing, o cualquier comunicación masiva no autorizada
- Distribuir malware, virus, ransomware, spyware, adware o cualquier software malicioso
- Realizar o facilitar ataques de denegación de servicio (DoS/DDoS)
- Alojar, distribuir o promover contenido de abuso sexual infantil (CSAM) — tolerancia cero
- Participar en actividades fraudulentas, robo de identidad o phishing
- Violar derechos de propiedad intelectual o derechos de autor de terceros
- Alojar o distribuir contenido relacionado con terrorismo o incitación a la violencia
- Realizar escaneos de puertos, enumeración de redes o actividades de reconocimiento no autorizadas
- Minar criptomonedas sin autorización expresa de Terranode
- Vender o revender el servicio sin autorización previa por escrito

5.2 **Uso Excesivo de Recursos.** Terranode se reserva el derecho de suspender o limitar servicios cuando un cliente haga uso excesivo de CPU, RAM, ancho de banda, I/O de disco u otros recursos que afecten a otros usuarios en la misma infraestructura.

5.3 **Contenido Legal para Adultos.** El contenido legal para adultos está permitido siempre que cumpla con todas las leyes aplicables, incluidas las relacionadas con la verificación de edad, y no viole ninguna otra disposición de estas políticas.` },
  { id: 'email', title: '6. Política de Correo Electrónico', content: `6.1 **Límites de Envío.** Para servicios de alojamiento compartido, los límites son: máximo 200 correos electrónicos por hora por dominio y hasta 20 destinatarios por mensaje individual.

6.2 **SPAM.** El envío de correo no solicitado (SPAM) constituye una violación directa e inmediata de estas políticas y resultará en la suspensión inmediata del servicio sin derecho a reembolso.

6.3 **Listas de Correo.** Las listas de correo masivo solo son permitidas si los destinatarios han otorgado su consentimiento explícito (opt-in) y existe un mecanismo funcional de baja (opt-out).

6.4 **Servidores Dedicados.** Los servidores dedicados no tienen límites de envío predefinidos, siempre que el correo sea legítimo y no constituya SPAM.` },
  { id: 'seguridad', title: '7. Seguridad', content: `7.1 **Responsabilidad del Cliente.** El cliente es el único responsable de mantener y supervisar la seguridad de sus cuentas, aplicaciones y datos. Esto incluye, sin limitación: gestión de contraseñas seguras, actualización regular de software, configuración correcta de permisos de archivos, y monitoreo de actividades inusuales.

7.2 **Notificación de Incidentes.** En caso de sospechar un incidente de seguridad, el cliente debe notificar a Terranode de inmediato a través de un ticket de soporte.

7.3 **Limitación de Responsabilidad de Terranode.** Terranode implementa medidas técnicas y organizativas razonables para proteger la infraestructura compartida, pero no puede garantizar seguridad absoluta frente a amenazas externas. Terranode no será responsable por daños derivados de ataques externos, vulnerabilidades en software de terceros instalado por el cliente, o accesos no autorizados resultantes de negligencia del cliente.` },
  { id: 'copias-seguridad', title: '8. Copias de Seguridad y Datos', content: `8.1 **Responsabilidad del Cliente.** Los datos almacenados en los servicios de Terranode son responsabilidad exclusiva del cliente. El cliente debe mantener copias de seguridad independientes de todos sus datos críticos.

8.2 **Backups de Terranode.** Terranode puede ofrecer servicios de backup como característica adicional. Sin embargo, estos backups se proporcionan como un complemento, sin garantía de integridad, disponibilidad o frecuencia. No deben considerarse el único mecanismo de protección de datos.

8.3 **Eliminación de Datos.** Al cancelar un servicio, los datos del cliente pueden ser eliminados de forma permanente. Terranode no se obliga a retener datos después de la cancelación o terminación del servicio. Se recomienda exportar todos los datos antes de cancelar.

8.4 **Pérdida de Datos.** Terranode no será responsable por pérdida de datos, pérdidas económicas, pérdida de beneficios, o cualquier daño indirecto, incidental, especial o consecuente derivado de la pérdida de datos.` },
  { id: 'ubicacion-servidores', title: '9. Ubicación de los Servidores y Transferencia de Datos', content: `Los servicios de Terranode pueden ser prestados desde servidores ubicados en Estados Unidos, Ecuador, y otras regiones geográficas según el tipo de servicio contratado. Al contratar nuestros servicios, el cliente acepta expresamente la transferencia y almacenamiento de sus datos en dichas ubicaciones.

El cliente es el único responsable de verificar que la transferencia internacional de datos sea compatible con las leyes de protección de datos aplicables en su jurisdicción. Terranode no se hace responsable de las implicaciones legales que puedan surgir por el almacenamiento de datos en servidores ubicados fuera de la jurisdicción del cliente.` },
  { id: 'propiedad-intelectual', title: '10. Propiedad Intelectual', content: `10.1 **Propiedad de Terranode.** Todos los contenidos, software, código, diseños, marcas, logotipos y demás elementos propiedad de Terranode están protegidos por las leyes de propiedad intelectual aplicables. Queda prohibida su reproducción, distribución o uso sin autorización expresa y por escrito de Terranode.

10.2 **Contenido del Cliente.** El cliente mantiene todos los derechos de propiedad intelectual sobre el contenido que aloje en los servicios de Terranode. El cliente otorga a Terranode una licencia limitada y no exclusiva para alojar, almacenar y transmitir dicho contenido con el único propósito de prestar el servicio contratado.

10.3 **Infracción de Derechos de Autor.** El cliente acepta indemnizar y mantener indemne a Terranode frente a cualquier reclamación derivada del uso ilegal de materiales protegidos por derechos de autor.` },
  { id: 'ips', title: '11. Direcciones IP', content: `Todas las direcciones de Protocolo de Internet (IP) asignadas a los servicios del cliente son propiedad de Terranode o de sus proveedores de upstream. Las direcciones IP no son transferibles y el cliente no adquiere ningún derecho de propiedad sobre ellas. Terranode se reserva el derecho de reasignar direcciones IP con notificación razonable al cliente.` },
  { id: 'suspension-terminacion', title: '12. Suspensión y Terminación', content: `12.1 **Por Terranode.** Terranode se reserva el derecho de suspender o terminar cualquier servicio, con o sin notificación previa, en caso de: violación de estas políticas, falta de pago, actividad ilegal, daño a la infraestructura o a otros usuarios, o a discreción exclusiva de Terranode cuando así lo considere necesario para proteger su red o la seguridad de sus clientes.

12.2 **Por el Cliente.** El cliente puede cancelar su servicio en cualquier momento mediante solicitud a través del panel de cliente o ticket de soporte. La cancelación no da derecho automático a reembolso fuera del período establecido en la Política de Reembolsos.

12.3 **Efectos de la Terminación.** Al producirse la terminación del servicio por cualquier causa, el cliente pierde el acceso a los servicios y datos almacenados. Terranode podrá eliminar permanentemente todos los datos del cliente sin obligación de conservarlos.` },
  { id: 'limitacion-responsabilidad', title: '13. Limitación de Responsabilidad', content: `13.1 En la máxima medida permitida por la ley aplicable, Terranode no será responsable por daños indirectos, incidentales, especiales, consecuentes o punitivos, incluyendo pérdida de beneficios, pérdida de datos, interrupción del negocio, o cualquier otro daño intangible.

13.2 La responsabilidad total de Terranode frente al cliente, por cualquier causa y sin importar la forma de la acción, estará limitada al importe total pagado por el cliente a Terranode durante los tres (3) meses anteriores al evento que dio lugar a la reclamación.

13.3 Terranode no garantiza que los servicios sean ininterrumpidos, libres de errores o completamente seguros. Los servicios se prestan "tal como están" y "según disponibilidad".` },
  { id: 'fuerza-mayor', title: '14. Fuerza Mayor', content: `Terranode no será responsable por retrasos o incumplimientos en la prestación de servicios causados por circunstancias fuera de su control razonable, incluyendo pero no limitado a: desastres naturales, ataques DDoS de gran escala, fallos en redes de telecomunicaciones de terceros, actos de guerra, terrorismo, huelgas, decisiones gubernamentales, pandemias, o cualquier otro evento de fuerza mayor.` },
  { id: 'privacidad', title: '15. Privacidad y Protección de Datos', content: `El tratamiento de datos personales se rige por nuestra Política de Privacidad, disponible en nuestro sitio web. Al utilizar nuestros servicios, el cliente acepta el tratamiento de sus datos según dicha política, que forma parte integral de estos Términos y Condiciones.

Terranode cumple con las disposiciones de la Ley Orgánica de Protección de Datos Personales (LOPDP) de Ecuador en lo que respecta a los datos de clientes residentes en dicho país.` },
  { id: 'menores', title: '16. Menores de Edad', content: `Los servicios de Terranode están dirigidos exclusivamente a personas mayores de 18 años. Terranode no recopila intencionalmente información personal de menores de edad. Si usted tiene conocimiento de que un menor ha proporcionado información personal a Terranode, por favor contáctenos inmediatamente para proceder a su eliminación.` },
  { id: 'ley-aplicable', title: '17. Ley Aplicable y Resolución de Disputas', content: `17.1 **Ley Aplicable.** Estos términos se rigen e interpretan de conformidad con las leyes de la República del Ecuador.

17.2 **Resolución de Disputas.** En caso de disputa, las partes intentarán en primer lugar resolverla de manera amistosa mediante negociación directa. Si no se alcanza un acuerdo en un plazo de 30 días, la disputa será sometida a los tribunales competentes de la ciudad de Guayaquil, Ecuador, a los cuales las partes se someten expresamente con renuncia a cualquier otro fuero o jurisdicción que pudiera corresponderles.` },
  { id: 'reportes', title: '18. Reporte de Violaciones y Abuso', content: `Para reportar violaciones a estas políticas, actividades de abuso, spam, o cualquier uso indebido de nuestra infraestructura, por favor contacte a nuestro equipo a través de un ticket de soporte en my.terranode.net o envíe un correo a info@terranode.net con el asunto "Reporte de Abuso".

Todo reporte debe incluir: nombre completo del reportante, información de contacto, dirección IP o URL involucrada, descripción detallada de la violación y evidencia relevante. Terranode revisará todos los reportes verificados y tomará las medidas apropiadas a su discreción.` },
  { id: 'cambios', title: '19. Modificaciones a estos Términos', content: `Terranode se reserva el derecho de modificar estos Términos y Condiciones en cualquier momento. Las modificaciones entrarán en vigencia a partir de su publicación en este sitio web. Se recomienda a los clientes revisar periódicamente esta página. En caso de cambios materiales, Terranode podrá notificar a los clientes activos mediante correo electrónico. El uso continuado de los servicios tras la publicación de modificaciones constituye la aceptación de los nuevos términos.` },
  { id: 'contacto', title: '20. Información de Contacto', content: `Para cualquier consulta relacionada con estos Términos y Condiciones:

**Terranode — Cloud Infrastructure**
Sitio web: https://terranode.net
Soporte: https://my.terranode.net
Correo: info@terranode.net
Teléfono: +593 99 819 7150
Guayaquil, Ecuador` },
];

export const TERMS_EN: LegalSection[] = [
  { id: 'acceptance', title: '1. Acceptance of Terms', content: `By accessing, registering for, or using any service offered by Terranode ("the Company", "we", "our"), you ("the Client") agree to be bound by these Terms and Conditions unconditionally. If you disagree with any part of these terms, you may not use our services.

These terms constitute a legally binding agreement between you and Terranode, governed by the laws in force in the Republic of Ecuador. Terranode reserves the right to modify these terms at any time by posting notice on this website. Continued use of the service after such changes constitutes your acceptance of the new terms.` },
  { id: 'services', title: '2. Service Description', content: `Terranode provides cloud infrastructure services including, without limitation: shared web hosting, virtual private servers (VPS), dedicated servers, corporate email (TerraMail), Microsoft 365, web development and systems development.

Services are activated upon payment confirmation. We reserve the right to modify, suspend or discontinue any service with reasonable prior notice to the client, except in cases of violations of these policies where suspension may be immediate.` },
  { id: 'accounts', title: '3. Client Accounts and Responsibilities', content: `3.1 **Accurate Information.** The client agrees to provide truthful, accurate, current and complete information during the registration process and to keep it updated.

3.2 **Account Security.** The client is solely responsible for maintaining the confidentiality of their access credentials and for all activities carried out under their account. Terranode shall not be liable for losses caused by unauthorized use of your account.

3.3 **Proper Use.** The client is responsible for ensuring that use of the services complies with all applicable local, national and international laws, as well as with these policies.

3.4 **Contact.** The client must maintain an active and valid email address to receive important communications about their account and the services.` },
  { id: 'payments', title: '4. Payments, Billing and Renewals', content: `4.1 **Pricing.** All prices are expressed in US Dollars (USD) unless otherwise stated. Prices may be subject to applicable taxes under Ecuadorian law.

4.2 **Billing.** Services are billed in advance according to the selected billing cycle (monthly, annual or other). Non-payment by the due date may result in service suspension without additional prior notice.

4.3 **Renewals.** Services renew automatically at the end of each billing cycle, unless the client cancels at least 24 hours before the renewal date.

4.4 **Suspension for Non-Payment.** Services unpaid by their due date will be suspended. Data may be permanently deleted after 15 days past due without payment, and Terranode is not responsible for data loss in this case.

4.5 **Destruction of VPS and Dedicated Servers.** For VPS and Dedicated Server services, once the service is cancelled, suspended for non-payment, or terminated for policy violation, the server will be immediately and irreversibly destroyed along with all data, snapshots, internal backups and configurations stored on it. Terranode will not retain any copy of the data nor will it have the ability to recover it once destruction has been executed. The client is solely responsible for exporting and backing up all their information before cancellation or in the event of anything that could lead to service termination.

4.6 **Chargebacks.** If a client initiates a chargeback or dispute with their financial institution, Terranode reserves the right to immediately suspend all services, share relevant information with the payment processor to contest the chargeback, and apply an administrative fee. Initiating a chargeback automatically waives the right to a refund under our policy.` },
  { id: 'acceptable-use', title: '5. Acceptable Use Policy', content: `5.1 **Prohibited Activities.** The client may not use Terranode services to:
- Send unsolicited email (SPAM), phishing, or any unauthorized mass communication
- Distribute malware, viruses, ransomware, spyware, adware or any malicious software
- Conduct or facilitate denial of service attacks (DoS/DDoS)
- Host, distribute or promote child sexual abuse material (CSAM) — zero tolerance
- Engage in fraudulent activities, identity theft or phishing
- Violate third-party intellectual property or copyright rights
- Host or distribute content related to terrorism or incitement to violence
- Perform port scanning, network enumeration or unauthorized reconnaissance activities
- Mine cryptocurrencies without express authorization from Terranode
- Sell or resell the service without prior written authorization

5.2 **Excessive Resource Use.** Terranode reserves the right to suspend or limit services when a client makes excessive use of CPU, RAM, bandwidth, disk I/O or other resources that affect other users on the same infrastructure.

5.3 **Legal Adult Content.** Legal adult content is permitted provided it complies with all applicable laws, including those related to age verification, and does not violate any other provision of these policies.` },
  { id: 'email', title: '6. Email Policy', content: `6.1 **Sending Limits.** For shared hosting services, the limits are: a maximum of 200 emails per hour per domain and up to 20 recipients per individual message.

6.2 **SPAM.** Sending unsolicited email (SPAM) constitutes a direct and immediate violation of these policies and will result in immediate service suspension without the right to a refund.

6.3 **Mailing Lists.** Bulk mailing lists are only permitted if recipients have granted explicit consent (opt-in) and a functional unsubscribe mechanism (opt-out) exists.

6.4 **Dedicated Servers.** Dedicated servers have no predefined sending limits, provided the email is legitimate and does not constitute SPAM.` },
  { id: 'security', title: '7. Security', content: `7.1 **Client Responsibility.** The client is solely responsible for maintaining and monitoring the security of their accounts, applications and data. This includes, without limitation: secure password management, regular software updates, correct file permission configuration, and monitoring of unusual activity.

7.2 **Incident Notification.** If a security incident is suspected, the client must notify Terranode immediately through a support ticket.

7.3 **Limitation of Terranode's Liability.** Terranode implements reasonable technical and organizational measures to protect shared infrastructure, but cannot guarantee absolute security against external threats. Terranode shall not be liable for damages arising from external attacks, vulnerabilities in third-party software installed by the client, or unauthorized access resulting from client negligence.` },
  { id: 'backups', title: '8. Backups and Data', content: `8.1 **Client Responsibility.** Data stored on Terranode services is the exclusive responsibility of the client. The client must maintain independent backups of all their critical data.

8.2 **Terranode Backups.** Terranode may offer backup services as an additional feature. However, these backups are provided as a supplement, without guarantee of integrity, availability or frequency. They should not be considered the sole data protection mechanism.

8.3 **Data Deletion.** Upon cancelling a service, client data may be permanently deleted. Terranode is not obligated to retain data after cancellation or termination of the service. It is recommended to export all data before cancelling.

8.4 **Data Loss.** Terranode shall not be liable for data loss, economic losses, loss of profits, or any indirect, incidental, special or consequential damages arising from data loss.` },
  { id: 'server-location', title: '9. Server Location and Data Transfer', content: `Terranode services may be provided from servers located in the United States, Ecuador, and other geographic regions depending on the type of service contracted. By contracting our services, the client expressly accepts the transfer and storage of their data in those locations.

The client is solely responsible for verifying that the international transfer of data is compatible with the data protection laws applicable in their jurisdiction. Terranode is not responsible for legal implications that may arise from storing data on servers located outside the client's jurisdiction.` },
  { id: 'intellectual-property', title: '10. Intellectual Property', content: `10.1 **Terranode Property.** All content, software, code, designs, trademarks, logos and other elements owned by Terranode are protected by applicable intellectual property laws. Their reproduction, distribution or use without express written authorization from Terranode is prohibited.

10.2 **Client Content.** The client retains all intellectual property rights over the content they host on Terranode services. The client grants Terranode a limited, non-exclusive license to host, store and transmit such content for the sole purpose of providing the contracted service.

10.3 **Copyright Infringement.** The client agrees to indemnify and hold Terranode harmless against any claim arising from the illegal use of copyright-protected materials.` },
  { id: 'ip-addresses', title: '11. IP Addresses', content: `All Internet Protocol (IP) addresses assigned to client services are the property of Terranode or its upstream providers. IP addresses are non-transferable and the client acquires no ownership rights over them. Terranode reserves the right to reassign IP addresses with reasonable notice to the client.` },
  { id: 'suspension', title: '12. Suspension and Termination', content: `12.1 **By Terranode.** Terranode reserves the right to suspend or terminate any service, with or without prior notice, in the event of: violation of these policies, non-payment, illegal activity, damage to the infrastructure or to other users, or at Terranode's sole discretion when deemed necessary to protect its network or the security of its clients.

12.2 **By the Client.** The client may cancel their service at any time by request through the client panel or a support ticket. Cancellation does not automatically entitle the client to a refund outside the period established in the Refund Policy.

12.3 **Effects of Termination.** Upon termination of the service for any cause, the client loses access to the services and stored data. Terranode may permanently delete all client data without any obligation to retain it.` },
  { id: 'liability', title: '13. Limitation of Liability', content: `13.1 To the maximum extent permitted by applicable law, Terranode shall not be liable for indirect, incidental, special, consequential or punitive damages, including loss of profits, data loss, business interruption, or any other intangible damage.

13.2 Terranode's total liability to the client, for any cause and regardless of the form of action, shall be limited to the total amount paid by the client to Terranode during the three (3) months preceding the event giving rise to the claim.

13.3 Terranode does not guarantee that the services will be uninterrupted, error-free or completely secure. Services are provided "as is" and "as available".` },
  { id: 'force-majeure', title: '14. Force Majeure', content: `Terranode shall not be liable for delays or failures in the provision of services caused by circumstances beyond its reasonable control, including but not limited to: natural disasters, large-scale DDoS attacks, failures in third-party telecommunications networks, acts of war, terrorism, strikes, government decisions, pandemics, or any other force majeure event.` },
  { id: 'privacy', title: '15. Privacy and Data Protection', content: `The processing of personal data is governed by our Privacy Policy, available on our website. By using our services, the client accepts the processing of their data under that policy, which forms an integral part of these Terms and Conditions.

Terranode complies with the provisions of Ecuador's Organic Law on Personal Data Protection (LOPDP) with respect to the data of clients residing in that country.` },
  { id: 'minors', title: '16. Minors', content: `Terranode services are directed exclusively at persons over 18 years of age. Terranode does not intentionally collect personal information from minors. If you become aware that a minor has provided personal information to Terranode, please contact us immediately so we can proceed with its deletion.` },
  { id: 'governing-law', title: '17. Governing Law and Dispute Resolution', content: `17.1 **Governing Law.** These terms are governed by and interpreted in accordance with the laws of the Republic of Ecuador.

17.2 **Dispute Resolution.** In the event of a dispute, the parties shall first attempt to resolve it amicably through direct negotiation. If no agreement is reached within 30 days, the dispute shall be submitted to the competent courts of the city of Guayaquil, Ecuador, to which the parties expressly submit, waiving any other jurisdiction that might correspond to them.` },
  { id: 'abuse-reports', title: '18. Reporting Violations and Abuse', content: `To report violations of these policies, abusive activities, spam, or any misuse of our infrastructure, please contact our team through a support ticket at my.terranode.net or send an email to info@terranode.net with the subject "Abuse Report".

Every report must include: the reporter's full name, contact information, the IP address or URL involved, a detailed description of the violation and relevant evidence. Terranode will review all verified reports and take appropriate action at its discretion.` },
  { id: 'changes', title: '19. Modifications to these Terms', content: `Terranode reserves the right to modify these Terms and Conditions at any time. Modifications take effect upon publication on this website. Clients are advised to review this page periodically. In the event of material changes, Terranode may notify active clients by email. Continued use of the services after modifications are published constitutes acceptance of the new terms.` },
  { id: 'contact', title: '20. Contact Information', content: `For any inquiries related to these Terms and Conditions:

**Terranode — Cloud Infrastructure**
Website: https://terranode.net
Support: https://my.terranode.net
Email: info@terranode.net
Phone: +593 99 819 7150
Guayaquil, Ecuador` },
];

// ══════════════════ POLÍTICA DE REEMBOLSOS ══════════════════
export const REFUND_SUMMARY_ES: SummaryCard[] = [
  { icon: '✅', color: '#22C55E', title: 'Garantía de 7 días', desc: 'Web Hosting y Correo Corporativo nuevos (primera contratación)' },
  { icon: '✅', color: '#22C55E', title: 'Garantía de 3 días', desc: 'VPS Server nuevos (primera contratación)' },
  { icon: '❌', color: '#EF4444', title: 'Sin reembolso — M365', desc: 'Microsoft 365: sin reembolso en ningún caso una vez activado' },
  { icon: '❌', color: '#EF4444', title: 'Sin reembolso', desc: 'Dominios, servicios renovados, servicios usados para violar políticas' },
  { icon: '⚠️', color: '#F59E0B', title: 'Un reembolso por cliente', desc: 'Solo aplicable en la primera contratación de cada tipo de servicio' },
  { icon: '🚫', color: '#F97316', title: 'Disputas y contracargos', desc: 'Si inicias un contracargo con tu banco sin agotar el proceso de reembolso, todos tus servicios serán suspendidos de inmediato' },
];

export const REFUND_SUMMARY_EN: SummaryCard[] = [
  { icon: '✅', color: '#22C55E', title: '7-day Guarantee', desc: 'New Web Hosting and Corporate Email (first-time purchase)' },
  { icon: '✅', color: '#22C55E', title: '3-day Guarantee', desc: 'New VPS Server (first-time purchase)' },
  { icon: '❌', color: '#EF4444', title: 'No Refund — M365', desc: 'Microsoft 365: no refund under any circumstance once activated' },
  { icon: '❌', color: '#EF4444', title: 'No Refund', desc: 'Domains, renewed services, services used to violate policies' },
  { icon: '⚠️', color: '#F59E0B', title: 'One refund per client', desc: 'Only applicable on first purchase of each service type' },
  { icon: '🚫', color: '#F97316', title: 'Disputes & Chargebacks', desc: 'If you initiate a chargeback with your bank without exhausting the refund process, all your services will be immediately suspended' },
];

export const REFUND_ES: LegalSection[] = [
  { id: 'compromiso', title: '1. Nuestro Compromiso', content: `Terranode se compromete a brindar servicios de alta calidad y a garantizar la satisfacción de nuestros clientes. Si experimenta algún problema con nuestros servicios, le instamos a contactar a nuestro equipo de soporte técnico antes de solicitar un reembolso. En la mayoría de los casos, podemos resolver problemas técnicos de manera rápida y efectiva.

Esta política de reembolsos aplica exclusivamente a servicios directamente prestados por Terranode. La fecha de entrada en vigor de la presente versión es el 20 de Marzo de 2026.` },
  { id: 'periodos', title: '2. Períodos de Garantía de Devolución', content: `A continuación se detallan los períodos de garantía de devolución por tipo de servicio. Todos los períodos se cuentan en días calendario desde la fecha de activación del servicio.

- **Web Hosting (Compartido):** 7 días calendario desde la activación.
- **Correo Corporativo (TerraMail):** 7 días calendario desde la activación.
- **VPS Server:** 3 días calendario desde la activación del servidor.
- **Servidores Dedicados:** Sin garantía estándar de devolución, dado el costo de aprovisionamiento del hardware. Las reclamaciones por defectos de hardware documentados se evaluarán caso a caso dentro de las primeras 72 horas.
- **Desarrollo Web y Sistemas:** No aplica esta política. Se rige por el contrato de servicios firmado entre las partes.

⚠ Microsoft 365 — SIN DERECHO A REEMBOLSO: Las licencias de Microsoft 365 no son reembolsables bajo ninguna circunstancia una vez activadas, dado que Terranode incurre en costos no recuperables ante Microsoft desde el momento de la activación. Al contratar Microsoft 365, el cliente acepta expresamente esta condición.

Transcurrido el período de garantía correspondiente, no se otorgarán reembolsos salvo en los casos excepcionales descritos en la sección 5.` },
  { id: 'condiciones', title: '3. Condiciones para Solicitar un Reembolso', content: `Para que una solicitud de reembolso sea válida, deben cumplirse todas las siguientes condiciones:

- La solicitud debe presentarse dentro del período de garantía aplicable
- El servicio debe ser contratado por primera vez (no aplica a renovaciones)
- El cliente no debe haber solicitado un reembolso previo para el mismo tipo de servicio
- El servicio no debe haber sido utilizado para violar los Términos y Condiciones
- No debe existir una disputa, contracargo o reclamación activa ante la entidad financiera
- El motivo del reembolso debe ser legítimo y documentable` },
  { id: 'proceso', title: '4. Proceso de Solicitud', content: `4.1 **Paso 1 — Contacto previo.** Antes de solicitar un reembolso, el cliente debe contactar al equipo de soporte mediante un ticket en my.terranode.net para intentar resolver el problema. Terranode se compromete a responder en un plazo máximo de 24 horas hábiles.

4.2 **Paso 2 — Solicitud formal.** Si el problema no puede resolverse, el cliente debe abrir un ticket de soporte con el asunto "Solicitud de Reembolso" incluyendo: número de cuenta o factura, servicio involucrado, fecha de contratación, motivo detallado de la solicitud, y evidencia del problema si aplica.

4.3 **Paso 3 — Revisión.** Terranode revisará la solicitud y notificará su decisión en un plazo máximo de 7 días hábiles.

4.4 **Paso 4 — Procesamiento.** Los reembolsos aprobados se procesarán mediante el mismo método de pago utilizado en la compra original en un plazo de 5 a 15 días hábiles adicionales, dependiendo de la entidad financiera.` },
  { id: 'exclusiones', title: '5. Exclusiones — Sin Derecho a Reembolso', content: `No se otorgarán reembolsos en los siguientes casos:

- **Dominios:** El registro, transferencia y renovación de nombres de dominio no son reembolsables bajo ninguna circunstancia, debido al carácter no reversible del proceso ante los registros.
- **Renovaciones:** Los servicios renovados (segunda contratación en adelante) no están cubiertos por la garantía de devolución.
- **Reembolso previo:** Si el cliente ya ha recibido un reembolso para el mismo tipo de servicio, no podrá solicitar otro bajo esta política.
- **Violación de políticas:** Servicios suspendidos o terminados por violación de los Términos y Condiciones o la Política de Uso Aceptable.
- **Contracargos activos:** Si el cliente ha iniciado una disputa o contracargo ante su institución financiera, la solicitud de reembolso directa queda automáticamente invalidada.
- **Uso excesivo de recursos:** Suspensiones por uso excesivo de CPU, RAM o ancho de banda.
- **Negligencia del cliente:** Pérdida de datos, problemas de seguridad o interrupciones ocasionadas por acciones u omisiones del propio cliente.
- **Servicios de desarrollo:** Los proyectos de desarrollo web/sistemas una vez iniciados, salvo acuerdo expreso por escrito.
- **Microsoft 365:** Las licencias de Microsoft 365 no son reembolsables bajo ninguna circunstancia una vez activadas. Terranode no puede recuperar estos costos ante Microsoft. Esta exclusión es absoluta e irrenunciable.
- **Otras licencias de software de terceros:** Incluyendo pero no limitado a licencias de cPanel u otro software ya activadas.
- **Caídas planificadas:** Interrupciones de servicio previamente anunciadas para mantenimiento.` },
  { id: 'excepciones', title: '6. Excepciones y Casos Especiales', content: `Terranode podrá considerar excepciones a la política estándar en los siguientes casos, a su exclusiva discreción y con documentación adecuada:

- **Fallo de hardware verificado** en servidores dedicados que impida el uso del servicio por más de 48 horas continuas, sin solución alternativa ofrecida
- **Error de facturación de Terranode** que resulte en un cobro duplicado o incorrecto
- **Imposibilidad total de activación** del servicio por causas imputables exclusivamente a Terranode, que persista por más de 72 horas desde la contratación

En estos casos excepcionales, Terranode podrá ofrecer, a su elección: un reembolso total o parcial, un crédito equivalente en la cuenta del cliente, o una extensión del período del servicio.` },
  { id: 'cancelacion', title: '7. Cancelación de Servicios', content: `El cliente puede cancelar cualquier servicio en cualquier momento desde el panel de cliente (my.terranode.net) o mediante ticket de soporte. La cancelación:

- No genera reembolso automático por el tiempo no utilizado fuera del período de garantía
- Detiene la facturación automática en el próximo ciclo
- Resulta en la pérdida de acceso al servicio al final del período pagado
- Puede resultar en la eliminación permanente de los datos almacenados

Se recomienda exportar todos los datos antes de proceder a la cancelación.` },
  { id: 'contracargos', title: '8. Política de Contracargos', content: `Si el cliente inicia un contracargo o disputa ante su institución financiera sin haber agotado previamente el proceso de solicitud de reembolso descrito en la sección 4:

- Todos los servicios activos del cliente serán suspendidos inmediatamente
- El cliente perderá el derecho a solicitar un reembolso directo bajo esta política
- Terranode presentará evidencia del servicio prestado ante el procesador de pagos y la institución financiera para impugnar el contracargo
- Podrá aplicarse una tarifa administrativa de hasta USD 25 por contracargo iniciado

Terranode entiende que los contracargos pueden ser resultado de fraude con tarjetas. En tales casos, el cliente debe notificarnos de inmediato para coordinar la solución adecuada.` },
  { id: 'creditos', title: '9. Créditos en Cuenta', content: `En algunos casos, en lugar de un reembolso monetario, Terranode podrá ofrecer créditos equivalentes en la cuenta del cliente, aplicables a futuros servicios. Los créditos en cuenta no tienen valor monetario fuera de la plataforma de Terranode, no son transferibles, y expiran a los 12 meses desde su otorgamiento.` },
  { id: 'modificaciones', title: '10. Modificaciones a esta Política', content: `Terranode se reserva el derecho de modificar esta Política de Reembolsos en cualquier momento. Las modificaciones entrarán en vigencia a partir de su publicación en el sitio web. Los clientes con solicitudes de reembolso en curso se regirán por la versión de la política vigente al momento de la contratación del servicio.` },
  { id: 'contacto', title: '11. Contacto', content: `Para solicitar un reembolso o consultas relacionadas con esta política:

Panel de Cliente: https://my.terranode.net
Correo: info@terranode.net
Teléfono: +593 99 819 7150
Guayaquil, Ecuador

El equipo de soporte está disponible 24/7.` },
];

export const REFUND_EN: LegalSection[] = [
  { id: 'commitment', title: '1. Our Commitment', content: `Terranode is committed to providing high-quality services and to ensuring the satisfaction of our clients. If you experience any problem with our services, we urge you to contact our technical support team before requesting a refund. In most cases, we can resolve technical problems quickly and effectively.

This refund policy applies exclusively to services directly provided by Terranode. The effective date of this version is March 20, 2026.` },
  { id: 'periods', title: '2. Money-Back Guarantee Periods', content: `Below are the money-back guarantee periods by service type. All periods are counted in calendar days from the service activation date.

- **Web Hosting (Shared):** 7 calendar days from activation.
- **Corporate Email (TerraMail):** 7 calendar days from activation.
- **VPS Server:** 3 calendar days from server activation.
- **Dedicated Servers:** No standard money-back guarantee, given the cost of hardware provisioning. Claims for documented hardware defects will be evaluated case by case within the first 72 hours.
- **Web and Systems Development:** This policy does not apply. Governed by the service contract signed between the parties.

⚠ Microsoft 365 — NO RIGHT TO REFUND: Microsoft 365 licenses are non-refundable under any circumstances once activated, since Terranode incurs non-recoverable costs with Microsoft from the moment of activation. By purchasing Microsoft 365, the client expressly accepts this condition.

Once the applicable guarantee period has elapsed, no refunds will be granted except in the exceptional cases described in section 5.` },
  { id: 'conditions', title: '3. Conditions to Request a Refund', content: `For a refund request to be valid, all of the following conditions must be met:

- The request must be submitted within the applicable guarantee period
- The service must be a first-time purchase (does not apply to renewals)
- The client must not have requested a previous refund for the same service type
- The service must not have been used to violate the Terms and Conditions
- There must be no active dispute, chargeback or claim with the financial institution
- The reason for the refund must be legitimate and documentable` },
  { id: 'process', title: '4. Request Process', content: `4.1 **Step 1 — Prior contact.** Before requesting a refund, the client must contact the support team via a ticket at my.terranode.net to attempt to resolve the problem. Terranode commits to responding within a maximum of 24 business hours.

4.2 **Step 2 — Formal request.** If the problem cannot be resolved, the client must open a support ticket with the subject "Refund Request" including: account or invoice number, service involved, purchase date, detailed reason for the request, and evidence of the problem if applicable.

4.3 **Step 3 — Review.** Terranode will review the request and notify its decision within a maximum of 7 business days.

4.4 **Step 4 — Processing.** Approved refunds will be processed via the same payment method used in the original purchase within 5 to 15 additional business days, depending on the financial institution.` },
  { id: 'exclusions', title: '5. Exclusions — No Right to Refund', content: `Refunds will not be granted in the following cases:

- **Domains:** The registration, transfer and renewal of domain names are non-refundable under any circumstances, due to the non-reversible nature of the process with the registries.
- **Renewals:** Renewed services (second purchase onward) are not covered by the money-back guarantee.
- **Previous refund:** If the client has already received a refund for the same service type, they may not request another under this policy.
- **Policy violations:** Services suspended or terminated for violating the Terms and Conditions or the Acceptable Use Policy.
- **Active chargebacks:** If the client has initiated a dispute or chargeback with their financial institution, the direct refund request is automatically invalidated.
- **Excessive resource use:** Suspensions for excessive use of CPU, RAM or bandwidth.
- **Client negligence:** Data loss, security problems or outages caused by the client's own actions or omissions.
- **Development services:** Web/systems development projects once started, unless expressly agreed in writing.
- **Microsoft 365:** Microsoft 365 licenses are non-refundable under any circumstances once activated. Terranode cannot recover these costs from Microsoft. This exclusion is absolute and non-waivable.
- **Other third-party software licenses:** Including but not limited to cPanel licenses or other software already activated.
- **Planned downtime:** Service interruptions previously announced for maintenance.` },
  { id: 'exceptions', title: '6. Exceptions and Special Cases', content: `Terranode may consider exceptions to the standard policy in the following cases, at its sole discretion and with adequate documentation:

- **Verified hardware failure** on dedicated servers that prevents use of the service for more than 48 continuous hours, with no alternative solution offered
- **Terranode billing error** resulting in a duplicate or incorrect charge
- **Total inability to activate** the service for reasons attributable exclusively to Terranode, persisting for more than 72 hours from purchase

In these exceptional cases, Terranode may offer, at its election: a total or partial refund, an equivalent credit to the client's account, or an extension of the service period.` },
  { id: 'cancellation', title: '7. Service Cancellation', content: `The client may cancel any service at any time from the client panel (my.terranode.net) or via support ticket. Cancellation:

- Does not generate an automatic refund for unused time outside the guarantee period
- Stops automatic billing at the next cycle
- Results in loss of access to the service at the end of the paid period
- May result in the permanent deletion of stored data

It is recommended to export all data before proceeding with cancellation.` },
  { id: 'chargebacks', title: '8. Chargeback Policy', content: `If the client initiates a chargeback or dispute with their financial institution without having first exhausted the refund request process described in section 4:

- All of the client's active services will be immediately suspended
- The client will lose the right to request a direct refund under this policy
- Terranode will submit evidence of the service provided to the payment processor and the financial institution to contest the chargeback
- An administrative fee of up to USD 25 per chargeback initiated may be applied

Terranode understands that chargebacks may result from card fraud. In such cases, the client must notify us immediately to coordinate an appropriate solution.` },
  { id: 'credits', title: '9. Account Credits', content: `In some cases, instead of a monetary refund, Terranode may offer equivalent credits to the client's account, applicable to future services. Account credits have no monetary value outside the Terranode platform, are non-transferable, and expire 12 months from the date they are granted.` },
  { id: 'modifications', title: '10. Modifications to this Policy', content: `Terranode reserves the right to modify this Refund Policy at any time. Modifications take effect upon publication on the website. Clients with refund requests in progress will be governed by the version of the policy in force at the time the service was purchased.` },
  { id: 'contact', title: '11. Contact', content: `To request a refund or for inquiries related to this policy:

Client Panel: https://my.terranode.net
Email: info@terranode.net
Phone: +593 99 819 7150
Guayaquil, Ecuador

The support team is available 24/7.` },
];

// ══════════════════ POLÍTICA DE PRIVACIDAD ══════════════════
export const PRIVACY_ES: LegalSection[] = [
  { id: 'intro', title: '1. Introducción e Identidad del Responsable', content: `La presente Política de Privacidad y Protección de Datos Personales (en adelante, "la Política") describe cómo Terranode S.A.S (en adelante, "Terranode", "nosotros" o "la empresa") recopila, usa, almacena, protege y trata los datos personales de sus clientes, usuarios y contactos.

Esta Política se encuentra elaborada en cumplimiento de la **Ley Orgánica de Protección de Datos Personales (LOPDP) del Ecuador**, publicada en el Registro Oficial Suplemento No. 459 del 26 de mayo de 2021, y su Reglamento de aplicación.

**Datos del Responsable del Tratamiento:**
- **Empresa:** Terranode S.A.S
- **Actividad:** Servicios de infraestructura en la nube, alojamiento web, VPS, servidores dedicados
- **Sitio web:** https://terranode.net
- **Correo de contacto para privacidad:** info@terranode.net
- **Teléfono:** +593 99 819 7150
- **Domicilio:** Guayaquil, República del Ecuador

Al contratar o usar cualquier servicio de Terranode, el usuario declara haber leído, comprendido y aceptado esta Política en su totalidad.` },
  { id: 'datos-recopilados', title: '2. Datos Personales que Recopilamos', content: `Terranode recopila únicamente los datos personales que son necesarios para la prestación de sus servicios y el cumplimiento de sus obligaciones legales. Los datos recopilados incluyen:

**2.1 Datos de Identificación y Contacto (obligatorios para el servicio):**
- Nombre completo o razón social
- Dirección de correo electrónico
- Número de teléfono
- Dirección física (para efectos de facturación)
- País y ciudad de residencia

**2.2 Datos de Facturación (obligatorios por ley tributaria ecuatoriana):**
- Número de Registro Único de Contribuyentes (RUC) o Cédula de Identidad (CI)
- Razón social o nombre del contribuyente
- Dirección de facturación
- Método de pago (datos de tarjeta son procesados por pasarelas de pago certificadas; Terranode no almacena datos completos de tarjetas)

**2.3 Datos Técnicos y de Uso (recopilados automáticamente):**
- Dirección IP del dispositivo de acceso
- Tipo y versión del navegador web
- Sistema operativo
- Páginas visitadas y tiempo de permanencia
- Logs de acceso al panel de control y a los servicios
- Registros de tickets de soporte y comunicaciones

**2.4 Datos Opcionales:**
- Información adicional proporcionada voluntariamente en formularios de contacto o tickets de soporte

No recopilamos datos sensibles como información médica, afiliación política, orientación sexual, creencias religiosas, ni datos biométricos.` },
  { id: 'finalidades', title: '3. Finalidades del Tratamiento', content: `Los datos personales recopilados son tratados exclusivamente para las siguientes finalidades:

**3.1 Finalidades Contractuales (necesarias para la prestación del servicio):**
- Creación y gestión de cuentas de usuario en la plataforma
- Provisión, activación y administración de los servicios contratados
- Envío de notificaciones técnicas relacionadas con el servicio (mantenimientos, incidentes, vencimientos)
- Atención de solicitudes de soporte técnico
- Gestión de renovaciones y cancelaciones de servicios

**3.2 Finalidades de Facturación y Cobro (obligación legal y contractual):**
- Emisión de facturas electrónicas en cumplimiento de la normativa tributaria ecuatoriana (SRI)
- Procesamiento de pagos y gestión de cobros
- Registro contable y tributario obligatorio
- Gestión de impagos y procedimientos de recuperación de deuda
- Cumplimiento de obligaciones ante la Administración Tributaria del Ecuador (SRI)

**3.3 Finalidades de Seguridad (interés legítimo):**
- Prevención y detección de fraudes, accesos no autorizados y actividades ilícitas
- Protección de la infraestructura técnica y de otros usuarios
- Cumplimiento de solicitudes legítimas de autoridades competentes

**3.4 Finalidades de Comunicación Comercial (con consentimiento):**
- Envío de comunicaciones sobre nuevos servicios, promociones o actualizaciones relevantes
- El cliente puede dar de baja estas comunicaciones en cualquier momento

Terranode **no utilizará** los datos personales para finalidades distintas a las declaradas sin obtener previamente el consentimiento del titular o sin amparo en otra base de legitimación legal.` },
  { id: 'base-legitimacion', title: '4. Base de Legitimación para el Tratamiento', content: `El tratamiento de datos personales realizado por Terranode se fundamenta en las siguientes bases legales según la LOPDP:

- **Ejecución de contrato:** El tratamiento es necesario para la prestación de los servicios contratados y la gestión de la relación comercial (Art. 22 LOPDP).
- **Obligación legal:** El tratamiento de datos de facturación es obligatorio en virtud de la Ley de Régimen Tributario Interno, el Código de Comercio y demás normativa tributaria y contable ecuatoriana (Art. 22 LOPDP).
- **Interés legítimo:** El tratamiento de datos técnicos y de seguridad está justificado por el interés legítimo de Terranode en proteger su infraestructura y la de sus clientes (Art. 22 LOPDP).
- **Consentimiento:** Las comunicaciones comerciales opcionales se realizan únicamente con el consentimiento expreso del titular (Art. 10 LOPDP).` },
  { id: 'conservacion', title: '5. Plazos de Conservación de los Datos', content: `Los datos personales serán conservados durante los siguientes plazos:

**Datos de facturación y contables:** 7 años desde la emisión de la factura, en cumplimiento de las obligaciones tributarias establecidas por el Servicio de Rentas Internas (SRI) del Ecuador y el Código de Comercio.

**Datos de la cuenta y servicios activos:** Durante toda la vigencia de la relación contractual y hasta 1 año después de la cancelación definitiva del último servicio activo.

**Datos técnicos y logs de acceso:** Entre 90 días y 1 año, según el tipo de log y los requisitos de seguridad aplicables.

**Datos de tickets de soporte:** 1 año desde la fecha de cierre del ticket.

**Datos para comunicaciones comerciales:** Hasta que el titular revoque su consentimiento.

Una vez vencidos estos plazos, los datos serán eliminados de forma segura o anonimizados, salvo que exista una obligación legal de conservación adicional o que sean necesarios para el ejercicio o defensa de reclamaciones.` },
  { id: 'transferencias', title: '6. Transferencias y Comunicaciones de Datos', content: `**6.1 No venta de datos.** Terranode no vende, alquila ni cede los datos personales de sus clientes a terceros con fines comerciales propios.

**6.2 Encargados del tratamiento.** Terranode puede compartir datos con terceros que actúan como encargados del tratamiento en nombre de Terranode, exclusivamente para prestar servicios necesarios:
- **Pasarelas de pago:** Para el procesamiento seguro de transacciones (bajo sus propias políticas de seguridad PCI-DSS).
- **Proveedores de infraestructura:** Empresas que proveen los centros de datos y conectividad donde se alojan los servicios (localizados en Ecuador, Estados Unidos y otras regiones).
- **Servicios de correo electrónico transaccional:** Para el envío de notificaciones y facturas.
- **Microsoft Corporation:** En el caso de servicios Microsoft 365, los datos necesarios para la activación de licencias son compartidos con Microsoft conforme a su política de privacidad.

**6.3 Transferencias internacionales.** Algunos de los proveedores mencionados pueden estar localizados fuera de Ecuador. En estos casos, Terranode adopta las medidas adecuadas para garantizar un nivel de protección equivalente al establecido por la LOPDP.

**6.4 Autoridades públicas.** Terranode podrá comunicar datos personales a autoridades públicas, judiciales o policiales cuando exista una obligación legal o una orden judicial que lo requiera.` },
  { id: 'derechos', title: '7. Derechos del Titular de los Datos', content: `De conformidad con la LOPDP, el titular de los datos personales tiene los siguientes derechos:

**Derecho de Acceso (Art. 68 LOPDP):** Conocer qué datos personales suyos son tratados por Terranode, el origen de dichos datos, las finalidades del tratamiento y los destinatarios.

**Derecho de Rectificación (Art. 69 LOPDP):** Solicitar la corrección de datos inexactos, incompletos o desactualizados.

**Derecho de Eliminación / Supresión (Art. 70 LOPDP):** Solicitar la eliminación de sus datos cuando ya no sean necesarios para las finalidades para las que fueron recopilados, siempre que no exista una obligación legal de conservación.

**Derecho de Oposición (Art. 72 LOPDP):** Oponerse al tratamiento de sus datos para finalidades de comunicaciones comerciales en cualquier momento y sin necesidad de justificación.

**Derecho a la Portabilidad (Art. 73 LOPDP):** Recibir los datos que haya proporcionado a Terranode en un formato estructurado, de uso común y lectura mecánica.

**Derecho a la Limitación del Tratamiento:** Solicitar que se restrinja el tratamiento de sus datos en determinadas circunstancias previstas por la ley.

**Ejercicio de Derechos:** Para ejercer cualquiera de los derechos anteriores, el titular debe enviar una solicitud por escrito a info@terranode.net o mediante ticket de soporte en my.terranode.net, indicando: nombre completo, número de cédula o RUC, correo electrónico de la cuenta, derecho que desea ejercer y motivación. Terranode responderá en un plazo máximo de 15 días hábiles.

Si el titular considera que sus derechos no han sido atendidos, puede presentar una reclamación ante la **Autoridad de Protección de Datos Personales del Ecuador** (ADPDE), una vez agotada la vía directa con Terranode.` },
  { id: 'seguridad', title: '8. Medidas de Seguridad', content: `Terranode implementa medidas técnicas y organizativas apropiadas para proteger los datos personales contra el acceso no autorizado, la pérdida, la destrucción o la divulgación accidental, entre ellas:

- Transmisión de datos cifrada mediante SSL/TLS en todas las comunicaciones web
- Controles de acceso basados en roles para el acceso a datos personales por parte del personal
- Procedimientos de gestión de contraseñas seguras en los sistemas internos
- Monitoreo y registro de accesos a sistemas que contienen datos personales
- Evaluaciones periódicas de seguridad de la infraestructura
- Políticas internas de confidencialidad para el personal con acceso a datos

No obstante lo anterior, ningún sistema de transmisión o almacenamiento de datos es completamente seguro. Terranode no puede garantizar seguridad absoluta. En caso de una brecha de seguridad que afecte a datos personales, Terranode notificará a los titulares afectados y a la autoridad competente conforme a lo establecido en la LOPDP.` },
  { id: 'cookies', title: '9. Cookies y Tecnologías de Seguimiento', content: `El sitio web de Terranode utiliza cookies y tecnologías similares para garantizar el correcto funcionamiento del sitio y mejorar la experiencia del usuario:

**Cookies estrictamente necesarias:** Indispensables para el funcionamiento del sitio. No pueden ser desactivadas.

**Cookies analíticas (Google Analytics):** Recopilan información anónima sobre el uso del sitio (páginas visitadas, tiempo de sesión, etc.) para mejorar el servicio. Los datos son tratados por Google LLC conforme a sus políticas de privacidad.

**Cookies de marketing (Meta Pixel):** Utilizadas para medir la efectividad de campañas publicitarias en Facebook e Instagram. Los datos son tratados por Meta Platforms conforme a sus políticas de privacidad.

El usuario puede gestionar sus preferencias de cookies a través de la configuración de su navegador. La desactivación de cookies analíticas o de marketing no afectará al funcionamiento del sitio ni a la prestación de los servicios.` },
  { id: 'menores', title: '10. Menores de Edad', content: `Los servicios de Terranode están dirigidos exclusivamente a personas mayores de 18 años. Terranode no recopila intencionalmente datos personales de menores de edad. Si tiene conocimiento de que un menor ha proporcionado datos personales a Terranode sin el consentimiento parental o tutelar, póngase en contacto con nosotros inmediatamente a través de info@terranode.net para proceder a su eliminación.` },
  { id: 'modificaciones', title: '11. Modificaciones a esta Política', content: `Terranode se reserva el derecho de actualizar esta Política de Privacidad en cualquier momento para reflejar cambios en la normativa aplicable, en nuestras prácticas de tratamiento de datos, o en los servicios que ofrecemos.

Las modificaciones entrarán en vigor a partir de su publicación en este sitio web. En caso de cambios materiales que afecten significativamente los derechos de los titulares, Terranode notificará a los clientes activos por correo electrónico con al menos 30 días de anticipación.

La fecha de la última actualización siempre estará visible al inicio de esta página.` },
  { id: 'contacto', title: '12. Contacto y Reclamaciones', content: `Para cualquier consulta, solicitud de derechos o reclamación relacionada con el tratamiento de sus datos personales:

**Terranode S.A.S**
Responsable de Protección de Datos: Administración Terranode
Correo: info@terranode.net
Panel de soporte: https://my.terranode.net
Teléfono: +593 99 819 7150
Guayaquil, República del Ecuador` },
];

export const PRIVACY_EN: LegalSection[] = [
  { id: 'intro', title: '1. Introduction and Identity of the Data Controller', content: `This Privacy and Personal Data Protection Policy (hereinafter, "the Policy") describes how Terranode S.A.S (hereinafter, "Terranode", "we" or "the company") collects, uses, stores, protects and processes the personal data of its clients, users and contacts.

This Policy has been prepared in compliance with the **Organic Law on Personal Data Protection (LOPDP) of Ecuador**, published in Official Gazette Supplement No. 459 of May 26, 2021, and its implementing Regulation.

**Data Controller Details:**
- **Company:** Terranode S.A.S
- **Activity:** Cloud infrastructure services, web hosting, VPS, dedicated servers
- **Website:** https://terranode.net
- **Privacy contact email:** info@terranode.net
- **Phone:** +593 99 819 7150
- **Address:** Guayaquil, Republic of Ecuador

By contracting or using any Terranode service, the user declares that they have read, understood and accepted this Policy in full.` },
  { id: 'data-collected', title: '2. Personal Data We Collect', content: `Terranode collects only the personal data necessary to provide its services and comply with its legal obligations. The data collected includes:

**2.1 Identification and Contact Data (required for the service):**
- Full name or company name
- Email address
- Phone number
- Physical address (for billing purposes)
- Country and city of residence

**2.2 Billing Data (required by Ecuadorian tax law):**
- Taxpayer Registration Number (RUC) or National ID (CI)
- Company name or taxpayer name
- Billing address
- Payment method (card data is processed by certified payment gateways; Terranode does not store full card data)

**2.3 Technical and Usage Data (collected automatically):**
- IP address of the accessing device
- Web browser type and version
- Operating system
- Pages visited and time spent
- Access logs to the control panel and services
- Support ticket and communication records

**2.4 Optional Data:**
- Additional information voluntarily provided in contact forms or support tickets

We do not collect sensitive data such as health information, political affiliation, sexual orientation, religious beliefs, or biometric data.` },
  { id: 'purposes', title: '3. Purposes of Processing', content: `The personal data collected is processed exclusively for the following purposes:

**3.1 Contractual Purposes (necessary to provide the service):**
- Creation and management of user accounts on the platform
- Provisioning, activation and administration of the contracted services
- Sending technical notifications related to the service (maintenance, incidents, expirations)
- Handling technical support requests
- Managing service renewals and cancellations

**3.2 Billing and Collection Purposes (legal and contractual obligation):**
- Issuance of electronic invoices in compliance with Ecuadorian tax regulations (SRI)
- Payment processing and collections management
- Mandatory accounting and tax records
- Management of non-payment and debt recovery procedures
- Compliance with obligations before Ecuador's Tax Administration (SRI)

**3.3 Security Purposes (legitimate interest):**
- Prevention and detection of fraud, unauthorized access and illicit activities
- Protection of the technical infrastructure and of other users
- Compliance with legitimate requests from competent authorities

**3.4 Commercial Communication Purposes (with consent):**
- Sending communications about new services, promotions or relevant updates
- The client may unsubscribe from these communications at any time

Terranode **will not use** personal data for purposes other than those declared without first obtaining the data subject's consent or without another legal basis for processing.` },
  { id: 'legal-basis', title: '4. Legal Basis for Processing', content: `The processing of personal data carried out by Terranode is based on the following legal grounds under the LOPDP:

- **Performance of a contract:** Processing is necessary to provide the contracted services and manage the commercial relationship (Art. 22 LOPDP).
- **Legal obligation:** The processing of billing data is mandatory under the Internal Tax Regime Law, the Commercial Code and other Ecuadorian tax and accounting regulations (Art. 22 LOPDP).
- **Legitimate interest:** The processing of technical and security data is justified by Terranode's legitimate interest in protecting its infrastructure and that of its clients (Art. 22 LOPDP).
- **Consent:** Optional commercial communications are sent only with the data subject's express consent (Art. 10 LOPDP).` },
  { id: 'retention', title: '5. Data Retention Periods', content: `Personal data will be retained for the following periods:

**Billing and accounting data:** 7 years from invoice issuance, in compliance with the tax obligations established by Ecuador's Internal Revenue Service (SRI) and the Commercial Code.

**Account and active service data:** For the entire duration of the contractual relationship and up to 1 year after the definitive cancellation of the last active service.

**Technical data and access logs:** Between 90 days and 1 year, depending on the log type and applicable security requirements.

**Support ticket data:** 1 year from the ticket closure date.

**Data for commercial communications:** Until the data subject withdraws their consent.

Once these periods have elapsed, the data will be securely deleted or anonymized, unless there is an additional legal retention obligation or the data is necessary for the exercise or defense of claims.` },
  { id: 'transfers', title: '6. Data Transfers and Disclosures', content: `**6.1 No sale of data.** Terranode does not sell, rent or transfer its clients' personal data to third parties for their own commercial purposes.

**6.2 Data processors.** Terranode may share data with third parties acting as data processors on Terranode's behalf, exclusively to provide necessary services:
- **Payment gateways:** For secure transaction processing (under their own PCI-DSS security policies).
- **Infrastructure providers:** Companies providing the data centers and connectivity where services are hosted (located in Ecuador, the United States and other regions).
- **Transactional email services:** For sending notifications and invoices.
- **Microsoft Corporation:** In the case of Microsoft 365 services, the data necessary for license activation is shared with Microsoft in accordance with its privacy policy.

**6.3 International transfers.** Some of the providers mentioned may be located outside Ecuador. In these cases, Terranode adopts appropriate measures to guarantee a level of protection equivalent to that established by the LOPDP.

**6.4 Public authorities.** Terranode may disclose personal data to public, judicial or police authorities when there is a legal obligation or court order requiring it.` },
  { id: 'rights', title: '7. Rights of the Data Subject', content: `In accordance with the LOPDP, the data subject has the following rights:

**Right of Access (Art. 68 LOPDP):** To know what personal data of theirs is processed by Terranode, the origin of that data, the purposes of processing and the recipients.

**Right of Rectification (Art. 69 LOPDP):** To request the correction of inaccurate, incomplete or outdated data.

**Right of Erasure / Deletion (Art. 70 LOPDP):** To request the deletion of their data when it is no longer necessary for the purposes for which it was collected, provided there is no legal retention obligation.

**Right to Object (Art. 72 LOPDP):** To object to the processing of their data for commercial communication purposes at any time and without needing to provide justification.

**Right to Portability (Art. 73 LOPDP):** To receive the data they have provided to Terranode in a structured, commonly used and machine-readable format.

**Right to Restriction of Processing:** To request that the processing of their data be restricted in certain circumstances provided by law.

**Exercising Your Rights:** To exercise any of the above rights, the data subject must send a written request to info@terranode.net or via a support ticket at my.terranode.net, indicating: full name, national ID or RUC number, account email address, the right they wish to exercise and the reason. Terranode will respond within a maximum of 15 business days.

If the data subject believes their rights have not been addressed, they may file a complaint with the **Personal Data Protection Authority of Ecuador** (ADPDE), once the direct route with Terranode has been exhausted.` },
  { id: 'security', title: '8. Security Measures', content: `Terranode implements appropriate technical and organizational measures to protect personal data against unauthorized access, loss, destruction or accidental disclosure, including:

- Encrypted data transmission via SSL/TLS in all web communications
- Role-based access controls for personnel access to personal data
- Secure password management procedures in internal systems
- Monitoring and logging of access to systems containing personal data
- Periodic security assessments of the infrastructure
- Internal confidentiality policies for personnel with access to data

Notwithstanding the above, no data transmission or storage system is completely secure. Terranode cannot guarantee absolute security. In the event of a security breach affecting personal data, Terranode will notify the affected data subjects and the competent authority as established by the LOPDP.` },
  { id: 'cookies', title: '9. Cookies and Tracking Technologies', content: `The Terranode website uses cookies and similar technologies to ensure the correct functioning of the site and to improve the user experience:

**Strictly necessary cookies:** Essential for the operation of the site. They cannot be disabled.

**Analytics cookies (Google Analytics):** Collect anonymous information about site usage (pages visited, session time, etc.) to improve the service. The data is processed by Google LLC in accordance with its privacy policies.

**Marketing cookies (Meta Pixel):** Used to measure the effectiveness of advertising campaigns on Facebook and Instagram. The data is processed by Meta Platforms in accordance with its privacy policies.

Users can manage their cookie preferences through their browser settings. Disabling analytics or marketing cookies will not affect the functioning of the site or the provision of services.` },
  { id: 'minors', title: '10. Minors', content: `Terranode services are directed exclusively at persons over 18 years of age. Terranode does not intentionally collect personal data from minors. If you become aware that a minor has provided personal data to Terranode without parental or guardian consent, please contact us immediately at info@terranode.net so we can proceed with its deletion.` },
  { id: 'modifications', title: '11. Modifications to this Policy', content: `Terranode reserves the right to update this Privacy Policy at any time to reflect changes in applicable regulations, in our data processing practices, or in the services we offer.

Modifications take effect upon publication on this website. In the event of material changes that significantly affect the rights of data subjects, Terranode will notify active clients by email at least 30 days in advance.

The date of the last update will always be visible at the top of this page.` },
  { id: 'contact', title: '12. Contact and Complaints', content: `For any inquiry, rights request or complaint related to the processing of your personal data:

**Terranode S.A.S**
Data Protection Officer: Terranode Administration
Email: info@terranode.net
Support panel: https://my.terranode.net
Phone: +593 99 819 7150
Guayaquil, Republic of Ecuador` },
];
