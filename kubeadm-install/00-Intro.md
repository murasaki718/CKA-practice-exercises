# CKA Preparation Guide

## Official CNCF Resources

* **CKA Certification Page:** [CNCF CKA](https://www.cncf.io/certification/cka/)
* **CKA Curriculum v1.33:** [PDF](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.33.pdf)

---

## Exam Focus Areas

You will be evaluated on **five core domains** in Kubernetes administration:

| Topic                                              | Weight | Practice Exercises                                                                                                                   |
| -------------------------------------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| Cluster Architecture, Installation & Configuration | 25%    | [Exercises](https://github.com/murasaki718/CKA-practice-exercises/blob/v1.33/cluster-architecture-installation-configuration.md) |
| Workloads & Scheduling                             | 15%    | [Exercises](https://github.com/murasaki718/CKA-practice-exercises/blob/v1.33/workloads-scheduling.md)                            |
| Services & Networking                              | 20%    | [Exercises](https://github.com/murasaki718/CKA-practice-exercises/blob/v1.33/services-networking.md)                             |
| Storage                                            | 10%    | [Exercises](https://github.com/murasaki718/CKA-practice-exercises/blob/v1.33/storage.md)                                         |
| Troubleshooting                                    | 30%    | [Exercises](https://github.com/murasaki718/CKA-practice-exercises/blob/v1.33/troubleshooting.md)                                 |

---

## Official Documentation References

* [Kubernetes Concepts](https://kubernetes.io/docs/concepts/)
* [Kubernetes Tasks](https://kubernetes.io/docs/tasks/)
* [Kubernetes Reference](https://kubernetes.io/docs/reference/)

---

## Additional Learning Resources

* [Tips to Crack the CKA Exam](https://medium.com/@pmvk/tips-to-crack-certified-kubernetes-administrator-cka-exam-c949c7a9bea1)
* [CKAD Practice Questions (useful for CKA too)](https://medium.com/bb-tutorials-and-thoughts/practice-enough-with-these-questions-for-the-ckad-exam-2f42d1228552)
* [CKA Lab Practice Exercises](https://github.com/stretchcloud/cka-lab-practice)
* [CKAD Exercises Repo (also helpful for CKA)](https://github.com/dgkanatsios/CKAD-exercises)

---

## Exam Format & Strategy

* **Practical, not multiple-choice:** You will solve 17 real-world Kubernetes problems in **3 hours**.
* **Multiple clusters:** Be careful to operate in the correct cluster to avoid wasted time.
* **Hands-on tasks:** Create pods, deployments, rollouts, configure clusters with `kubeadm`, repair failing clusters, and perform other administrative operations.

---

## Recommended Preparation Steps

1. **Deepen Core Knowledge:**

   * Consider Kelsey Hightower’s [*Kubernetes the Hard Way*](https://github.com/kelseyhightower/kubernetes-the-hard-way/tree/master/docs) for a detailed understanding of Kubernetes internals.
   * You do **not** need to memorize it, but it builds strong foundational knowledge.

2. **Practice Exam-Like Exercises:**

   * Repeat exercises similar to real exam scenarios (linked above).
   * Learn to navigate official Kubernetes documentation efficiently, since only one browser tab is allowed during the exam.

3. **Become Efficient with CLI and Templates:**

   * Familiarize yourself with `kubectl`, YAML manifests, deployments, services, and troubleshooting workflows.
   * Comfort with templates and the CLI reduces exam stress and improves speed.

---

## Exam Logistics

* Online exam with webcam monitoring.
* Desk must be clear, with only a bottle of water allowed.
* Breaks are allowed but the timer continues.
* Duration: 3 hours; average completion time with preparation: 1.5–2 hours.

---

**Final Note:**
If you are new to Kubernetes, allow extra practice time. Experienced Kubernetes users should focus on speed, efficiency, and familiarity with documentation and CLI workflows.

**Good luck!**

---

I can also make a **condensed “quick-reference CKA prep sheet”** based on this, perfect for last-minute review. Do you want me to create that?
